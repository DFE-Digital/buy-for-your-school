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
          @cases = Case.all_cases_tab(@all_cases_filter_form).paginate(page: params[:cases_page]).load_async
          @new_cases = Case.new_cases_tab(@new_cases_filter_form).paginate(page: params[:new_cases_page]).load_async
          @my_cases = Case.my_cases_tab(current_agent, @my_cases_filter_form).paginate(page: params[:my_cases_page]).load_async

          if Flipper.enabled?(:cms_triage_view)
            @triage_cases = Case.triage_cases_tab(@triage_cases_filter_form).paginate(page: params[:triage_cases_page]).load_async
          end
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
      defaults = { state: %w[all], category: %w[all], agent: %w[all], procurement_stage: %w[all], level: %w[all], sort_by: "action", sort_order: "descending" }
      @all_cases_filter_form = Support::Case::Filtering.new(filter_params_for(:filter_all_cases_form, defaults:))
      @new_cases_filter_form = Support::Case::Filtering.new(filter_params_for(:filter_new_cases_form, defaults:))
      @my_cases_filter_form = Support::Case::Filtering.new(filter_params_for(:filter_my_cases_form, defaults: defaults.merge({ state: %w[live] })))

      if Flipper.enabled?(:cms_triage_view)
        @triage_cases_filter_form = Support::Case::Filtering.new(filter_params_for(:filter_triage_cases_form, defaults: defaults.merge({ state: %w[live] })))
      end
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
