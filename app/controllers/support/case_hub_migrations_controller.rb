module Support
  class CaseHubMigrationsController < ApplicationController
    def new
      @case_hub_migration_form = CaseHubMigrationForm.new
      @back_url = support_cases_path
    end

    def create
      @case_hub_migration_form = CaseHubMigrationForm.from_validation(validation)
      if validation.success?
        render :show
      else
        render :new
      end
    end

    def edit
      @case_hub_migration_form = CaseHubMigrationForm.from_validation(validation)
      if params[:button]== "change"
        render :new
      elsif params[:button]=="create"
        @case_hub_migration_form.persist
        redirect_to case_path
      end
    end

    def show; end

    def update; end

  private

    def validation
      CaseHubMigrationFormSchema.new.call(**case_hub_migration_form_params)
    end

    def case_hub_migration_form_params
      params.require(:case_hub_migration_form).permit(
        :school_urn,
        :contact_name,
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
