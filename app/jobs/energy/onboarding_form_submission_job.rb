module Energy
  class OnboardingFormSubmissionJob < ApplicationJob
    queue_as :default

    def perform(onboarding_case_id:, to_recipients:)
      @onboarding_case_id = onboarding_case_id
      Energy::Emails::OnboardingFormSubmissionMailer.new(onboarding_case:, to_recipients:).call
    end

  private

    def onboarding_case
      @onboarding_case ||= Energy::OnboardingCase.find(@onboarding_case_id)
    end
  end
end
