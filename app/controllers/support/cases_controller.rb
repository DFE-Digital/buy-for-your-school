module Support
  class CasesController < Cases::ApplicationController
    require "will_paginate/array"
    before_action :filter_forms, only: %i[index]
    before_action :current_case, only: %i[show edit]

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
          @cases = @all_cases_filter_form.results.paginate(page: params[:cases_page])
          @triage_cases = @triage_cases_filter_form.results.paginate(page: params[:triage_cases_page]) if Flipper.enabled?(:cms_triage_view)
          @new_cases = @new_cases_filter_form.results.paginate(page: params[:new_cases_page])
          @my_cases = @my_cases_filter_form.results.paginate(page: params[:my_cases_page])
        end
      end
    end

    def show
      session[:back_link] = url_from(back_link_param) unless back_link_param.nil?
      @back_url = url_from(back_link_param) || session[:back_link] || support_cases_path
    end

    def new
      @form = CreateCaseForm.new
      @back_url = support_cases_path
    end

    def create
      @form = CreateCaseForm.from_validation(validation)

      if validation.success? && params[:button] == "create"
        kase = @form.create_case

        create_interaction(kase.id, "create_case", "Case created", @form.to_h.slice(:source, :category))

        redirect_to support_case_path(kase)
      else
        render :new
      end
    end

    def edit
      return redirect_to support_case_path(current_case) unless current_case.created_manually?

      @back_url = support_case_path(current_case)
    end

    def update
      @form = EditCaseForm.from_validation(edit_validation)
      if edit_validation.success?
        current_case.update!(**@form.to_h)
        redirect_to support_case_path(current_case), notice: I18n.t("support.case_description.flash.updated")
      else
        render :edit
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

    def validation
      CreateCaseFormSchema.new.call(**form_params)
    end

    def edit_validation
      EditCaseFormSchema.new.call(**edit_form_params)
    end

    def form_params
      params.require(:create_case_form).permit(
        :organisation_urn,
        :organisation_name,
        :organisation_id,
        :organisation_type,
        :first_name,
        :last_name,
        :email,
        :phone_number,
        :extension_number,
        :category_id,
        :query_id,
        :estimated_procurement_completion_date,
        :estimated_savings,
        :progress_notes,
        :request_type,
        :source,
        :request_text,
        :other_category,
        :other_query,
        :procurement_amount,
      )
    end

    def filter_forms
      # allow my-cases to conditionally show closed / resolved cases if not by default
      my_cases_form_params = { defaults: { state: "live" } }.merge(filter_params_for(:filter_my_cases_form))
        .merge(base_cases: Case.by_agent(current_agent.id))

      all_cases_form_params = filter_params_for(:filter_all_cases_form)

      new_cases_form_params = filter_params_for(:filter_new_cases_form)
        .merge(base_cases: Case.initial)

      if Flipper.enabled?(:cms_triage_view)
        triage_cases_form_params = filter_params_for(:filter_triage_cases_form)
          .merge(base_cases: Case.triage, defaults: { state: "live" })

        @triage_cases_filter_form = CaseFilterForm.new(**triage_cases_form_params)
      end
      @new_cases_filter_form = CaseFilterForm.new(**new_cases_form_params)
      @my_cases_filter_form = CaseFilterForm.new(**my_cases_form_params)
      @all_cases_filter_form = CaseFilterForm.new(**all_cases_form_params)
    end

    def edit_form_params
      params.require(:edit_case_form).permit(:request_text)
    end

    def tower_tab_params(tab)
      tab_params = params.fetch(:tower, {})
      tab_params.fetch(tab, {}).permit!
    end
  end
end
