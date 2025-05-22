module Cec
  class OnboardingCasesController < Cec::ApplicationController
    before_action :filter_forms, only: %i[index]

    include Support::Concerns::FilterParameters

    def index
      session.delete(:back_link)

      respond_to do |format|
        format.json do
          @cases = CaseSearch.omnisearch(params[:q])
        end

        format.html do
          @all_cases = @all_cases_filter_form.results.paginate(page: params[:all_cases_page]).load_async
          @my_cases = @my_cases_filter_form.results.paginate(page: params[:my_cases_page]).load_async
        end
      end
    end

  private

    def filter_forms
      @all_cases_filter_form = Support::Case.dfe_energy.filtering(filter_params_for(:filter_all_cases_form))
      @my_cases_filter_form = Support::Case.dfe_energy.by_agent(current_agent.id).filtering(filter_params_for(:filter_my_cases_form))
    end
  end
end
