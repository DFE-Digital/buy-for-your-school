class Energy::CheckYourAnswersController < Energy::ApplicationController
  before_action :organisation_details
  before_action { @back_url = energy_school_selection_path }

  def show
    # There'll only be ONE for single flow, potentially many for MAT flow
    @organisation_task_lists = onboarding_case.onboarding_case_organisations.map do |org|
      Energy::TaskList.new(org.energy_onboarding_case_id, context: "check")
    end
  end
end

