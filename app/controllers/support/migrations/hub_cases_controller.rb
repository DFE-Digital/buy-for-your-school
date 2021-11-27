# frozen_string_literal: true

module Support
  class Migrations::HubCasesController < Support::Migrations::BaseController
    def new
      @form = CaseHubMigrationForm.new
      @back_url = support_cases_path
    end

    def create
      @form = CaseHubMigrationForm.from_validation(validation)
      if validation.success? && params[:button] == "create"
        kase = CreateCase.new(@form.to_h).call
        redirect_to support_case_path(kase)
      else
        render :new
      end
    end
  end
end
