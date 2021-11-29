# frozen_string_literal: true

module Support
  class Migrations::PreviewsController < Support::Migrations::BaseController
    def create
      @form = CaseHubMigrationFormPresenter.new(CaseHubMigrationForm.from_validation(validation))
      if validation.success?
        binding.pry
        render "support/migrations/previews/new"
      else
        render "support/migrations/hub_cases/new"
      end
    end
  end
end
