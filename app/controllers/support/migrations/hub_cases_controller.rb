module Support
  class Migrations::HubCasesController < Support::Migrations::BaseController
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
  end
end
