module Support
  class Migrations::BaseController < ApplicationController
  private

    def validation
      CaseHubMigrationFormSchema.new.call(**case_hub_migration_form_params)
    end

    def case_hub_migration_form_params
      params.require(:case_hub_migration_form).permit(
        :school_urn,
        :contact_first_name,
        :contact_last_name,
        :contact_email,
        :contact_phone_number,
        :buying_category,
        :hub_case_ref,
        :estimated_procurement_completion_date,
        :estimated_savings,
        :hub_notes,
        :progress_notes,
      )
    end
  end
end
