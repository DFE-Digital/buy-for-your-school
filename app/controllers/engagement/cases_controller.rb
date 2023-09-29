module Engagement
  class CasesController < ::Engagement::ApplicationController
    before_action :filter_forms, only: %i[index]
    before_action :current_case, only: %i[show]

    include Support::Concerns::HasInteraction
    include Support::Concerns::FilterParameters

    def index
      session.delete(:back_link)

      respond_to do |format|
        format.json do
          @cases = CaseSearch.omnisearch(params[:q])
        end

        format.html do
          @cases = @all_cases_filter_form.results.paginate(page: params[:cases_page])
        end
      end
    end

    def show
      session[:back_link] = url_from(back_link_param) unless back_link_param.nil?
      @back_url = url_from(back_link_param) || session[:back_link] || engagement_cases_path
    end

  private

    def current_case
      @current_case ||= Support::CasePresenter.new(Support::Case.find_by(id: params[:id]))
    end

    def filter_forms
      @all_cases_filter_form = Support::Case.created_by_e_and_o.filtering(filter_params_for(:filter_all_cases_form))
    end
  end
end
