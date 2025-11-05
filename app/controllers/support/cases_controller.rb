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
      unless energy_onboarding_case.nil?
        @organisation_task_lists = energy_onboarding_case.onboarding_case_organisations.map do |org|
          Energy::TaskList.new(org.energy_onboarding_case_id)
        end
      end
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

    def energy_onboarding_case
      @energy_onboarding_case ||= Energy::OnboardingCase.find_by(support_case_id: current_case.id)
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

    def authorize_agent_scope = :access_proc_ops_portal?

    helper_method def portal_new_case_assignments_path(current_case)
      send("new_#{portal_namespace}_case_assignment_path", current_case)
    end

    helper_method def portal_new_case_interaction_path(current_case, additional_params = {})
      if is_user_cec_agent?
        send("cec_case_new_interaction_path", current_case, additional_params)
      else
        send("new_support_case_interaction_path", current_case, additional_params)
      end
    end

    helper_method def portal_case_on_hold_path(current_case)
      send("#{portal_namespace}_case_on_hold_path", current_case)
    end

    helper_method def portal_case_opening_path(current_case)
      send("#{portal_namespace}_case_opening_path", current_case)
    end

    helper_method def portal_new_case_opening_path(current_case)
      if is_user_cec_agent?
        send("cec_case_new_opening_path", current_case)
      else
        send("new_support_case_opening_path", current_case)
      end
    end

    helper_method def portal_new_case_resolution_path(current_case)
      if is_user_cec_agent?
        send("cec_case_new_resolution_path", current_case)
      else
        send("new_support_case_resolution_path", current_case)
      end
    end

    helper_method def portal_case_closures_path(current_case)
      send("#{portal_namespace}_case_closures_path", current_case)
    end
  end
end
