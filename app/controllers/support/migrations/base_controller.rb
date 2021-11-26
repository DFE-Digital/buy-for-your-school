module Support
  class Migrations::BaseController < ApplicationController
  private

    def validation
      CaseHubMigrationFormSchema.new.call(**case_hub_migration_form_params)
    end

    def case_hub_migration_form_params
      params.require(:case_hub_migration_form).permit(
        :school_urn,
        :organisation_id,
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
