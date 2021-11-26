module Support
  class Migrations::PreviewsController < Support::Migrations::BaseController
    def new
      @form = CaseHubMigrationForm.new
      @back_url = support_cases_path
    end

    def create
      @form = CaseHubMigrationFormPresenter.new(CaseHubMigrationForm.from_validation(validation))
      if validation.success?
        render "support/migrations/previews/new"
      else
        render "support/migrations/hub_cases/new"
      end
    end
  end
end
