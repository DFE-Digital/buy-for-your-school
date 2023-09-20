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
        :extension_number,
        :discovery_method,
        :discovery_method_other_text,
        :category_id,
        :query_id,
        :other_category,
        :other_query,
        :estimated_procurement_completion_date,
        :estimated_savings,
        :progress_notes,
        :request_type,
        :source,
        :request_text,
        :procurement_amount,
      )
    end
  end
end
