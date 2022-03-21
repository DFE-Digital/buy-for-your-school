module Support
  class CasesController < Cases::ApplicationController
    require "will_paginate/array"
    before_action :filter_forms, only: %i[index]
    before_action :current_case, only: %i[show edit]

    include Concerns::HasInteraction

    def index
      respond_to do |format|
        format.json do
          @cases = CaseSearch.omnisearch(params[:q])
        end

        format.html do
          @cases = FilterCases.new.filter(params[:filter_all_cases_form]).order("ref DESC").map { |c| CasePresenter.new(c) }.paginate(page: params[:cases_page])
          @new_cases = FilterCases.new.filter(params[:filter_new_cases_form]).initial.order(created_at: :desc).map { |c| CasePresenter.new(c) }.paginate(page: params[:new_cases_page])
          @my_cases = FilterCases.new.filter(params[:filter_my_cases_form]).where.not(state: :closed).by_agent(current_agent&.id).order(created_at: :desc).map { |c| CasePresenter.new(c) }.paginate(page: params[:my_cases_page])
        end
      end
    end

    def show
      @back_url = support_cases_path
    end

    def new
      @form = CreateCaseForm.new
      @back_url = support_cases_path
    end

    def create
      @form = CreateCaseForm.from_validation(validation)
      if validation.success? && params[:button] == "create"
        kase = CreateCase.new(@form.to_h).call
        create_interaction(kase.id, "hub_notes", form_params["hub_notes"]) if form_params["hub_notes"].present?
        create_interaction(kase.id, "hub_progress_notes", form_params["progress_notes"]) if form_params["progress_notes"].present?
        create_interaction(kase.id, "hub_migration", "Case Migration Data", @form.to_h)
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
        :hub_case_ref,
        :estimated_procurement_completion_date,
        :estimated_savings,
        :hub_notes,
        :progress_notes,
        :request_type,
      )
    end

    def filter_forms
      @my_cases_filter_form = CaseFilterForm.new
      @new_cases_filter_form = CaseFilterForm.new
      @all_cases_filter_form = CaseFilterForm.new
    end

    def edit_form_params
      params.require(:edit_case_form).permit(:request_text)
    end
  end
end
