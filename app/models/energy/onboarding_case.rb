class Energy::OnboardingCase < ApplicationRecord
  belongs_to :support_case, class_name: "Support::Case"
  has_many :onboarding_case_organisations, class_name: "Energy::OnboardingCaseOrganisation", foreign_key: "energy_onboarding_case_id"

  def submitted?
    submitted_at.present?
  end
end
