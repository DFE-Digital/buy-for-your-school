# frozen_string_literal: true

module Support
  class Cases::PreviewsController < Support::CasesController
    def create
      @form = CreateCaseFormPresenter.new(CreateCaseForm.from_validation(validation))
      if validation.success?
        render "support/cases/previews/new"
      else
        render "support/cases/new"
      end
    end

  private

    def validation
      CreateCaseFormSchema.new.call(**form_params)
    end

    def form_params
      params.require(:create_case_form).permit(
        :organisation_id,
        :organisation_name,
        :organisation_type,
        :organisation_urn,
        :first_name,
        :last_name,
        :email,
        :phone_number,
        :category_id,
        :hub_case_ref,
        :estimated_procurement_completion_date,
        :estimated_savings,
        :hub_notes,
        :progress_notes,
      )
    end
  end
end
