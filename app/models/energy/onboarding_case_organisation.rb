class Energy::OnboardingCaseOrganisation < ApplicationRecord
  belongs_to :energy_onboarding_case
  belongs_to :support_case_organisation
end
