class Energy::CheckYourAnswersController < Energy::ApplicationController
  before_action :organisation_details
  before_action { @back_url = energy_case_tasks_path }

  def show
    # There'll only be ONE for single flow, potentially many for MAT flow
    @organisation_task_lists = onboarding_case.onboarding_case_organisations.map do |org|
      Energy::TaskList.new(org.energy_onboarding_case_id, context: "check")
    end
    @continue_button_route = continue_button_route
  end

  private

  def continue_button_route
    # Works for single flow as only one, may need to change for MATs
    energy_case_org = onboarding_case.onboarding_case_organisations.first
    if energy_case_org.vat_rate == 5 && !energy_case_org.vat_certificate_declared
      energy_case_org_vat_certificate_path(vat_declaration_prompt: "1", org_id: energy_case_org.onboardable_id)
    else
      energy_case_letter_of_authorisation_path
    end
  end
end
