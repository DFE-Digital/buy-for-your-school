class Energy::OnboardingCase < ApplicationRecord
  belongs_to :support_case, class_name: "Support::Case"
  has_many :energy_onboarding_case_organisations, class_name: "Energy::OnboardingCaseOrganisation", foreign_key: "energy_onboarding_case_id"
end
