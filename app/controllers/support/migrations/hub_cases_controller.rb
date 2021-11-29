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
        create_interaction(kase.id, "hub_notes", form_params["hub_notes"]) if form_params["hub_notes"].present?
        create_interaction(kase.id, "hub_progress_notes", form_params["progress_notes"]) if form_params["progress_notes"].present?
        redirect_to support_case_path(kase)
      else
        render :new
      end
    end

  private

    def create_interaction(kase_id, event_type, body)
      CreateInteraction.new(kase_id, event_type, current_agent.id, { body: body }).call
    end
  end
end
