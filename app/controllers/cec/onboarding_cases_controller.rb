module Cec
  class OnboardingCasesController < Cec::ApplicationController
    before_action :filter_forms, only: %i[index]
    before_action :current_case, only: %i[show]

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

    def show
      session[:back_link] = url_from(back_link_param) unless back_link_param.nil?
      @back_url = url_from(back_link_param) || session[:back_link] || cec_onboarding_cases_path
    end

  private

    def current_case
      @current_case ||= Support::CasePresenter.new(Support::Case.find_by(id: params[:id]))
    end

    def filter_forms
      @all_cases_filter_form = Support::Case.dfe_energy.filtering(filter_params_for(:filter_all_cases_form))
      @my_cases_filter_form = Support::Case.dfe_energy.by_agent(current_agent.id).filtering(filter_params_for(:filter_my_cases_form))
    end

    helper_method def portal_new_case_assignments_path(current_case)
      send("#{portal_namespace}_case_assignment_new_path", current_case)
    end
  end
end
