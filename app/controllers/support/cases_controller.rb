module Support
  class CasesController < Cases::ApplicationController
    require "will_paginate/array"
    before_action :filter_forms, only: %i[index]
    before_action :current_case, only: %i[show]

    helper_method :tower_tab_params

    include Support::Concerns::HasInteraction
    include Support::Concerns::FilterParameters

    content_security_policy do |policy|
      policy.style_src_attr :unsafe_inline
    end

    def index
      session.delete(:back_link)

      respond_to do |format|
        format.json do
          @cases = CaseSearch.omnisearch(params[:q])
        end

        format.html do
          @cases = @all_cases_filter_form.results.paginate(page: params[:cases_page]).load_async
          @new_cases = @new_cases_filter_form.results.paginate(page: params[:new_cases_page]).load_async
          @my_cases = @my_cases_filter_form.results.paginate(page: params[:my_cases_page]).load_async
          @triage_cases = @triage_cases_filter_form.results.paginate(page: params[:triage_cases_page]).load_async
        end
      end
    end

    def show
      session[:back_link] = url_from(back_link_param) unless back_link_param.nil?
      @back_url = url_from(back_link_param) || session[:back_link] || support_cases_path
      @request = FrameworkRequestPresenter.new(current_case.request)
    end

  private

    # @return [CasePresenter, nil]
    def current_case
      @current_case ||= CasePresenter.new(Case.find_by(id: params[:id]))
    end

    # @return [AgentPresenter, nil]
    def current_agent
      AgentPresenter.new(super) if super
    end

    def filter_forms
      defaults = { state: %w[all], category: %w[all], agent: %w[all], procurement_stage: %w[all], level: %w[all], sort_by: "action", sort_order: "descending" }
      @all_cases_filter_form = Case.filtering(filter_params_for(:filter_all_cases_form, defaults:, persist: !override_filter(:filter_all_cases_form)).except(:override))
      @new_cases_filter_form = Case.initial.filtering(filter_params_for(:filter_new_cases_form, defaults:))
      @my_cases_filter_form = Case.by_agent(current_agent.id).filtering(filter_params_for(:filter_my_cases_form, defaults: defaults.merge({ state: %w[live] })))
      @triage_cases_filter_form = Case.triage.filtering(filter_params_for(:filter_triage_cases_form, defaults: defaults.merge({ state: %w[live] }), persist: !override_filter(:filter_triage_cases_form)).except(:override))
    end

    def override_filter(filter_scope) = params.fetch(filter_scope, {}).permit(:override)[:override] == "true"

    def tower_tab_params(tab)
      tab_params = params.fetch(:tower, {})
      tab_params.fetch(tab, {}).permit!
    end
  end
end
