class Energy::OnboardingCase < ApplicationRecord
  belongs_to :support_case, class_name: "Support::Case"
  has_many :onboarding_case_organisations, class_name: "Energy::OnboardingCaseOrganisation", foreign_key: "energy_onboarding_case_id"

  after_save :update_support_case_timestamp

  def submitted?
    submitted_at.present?
  end

private

  def update_support_case_timestamp
    support_case.touch if support_case.present?
  end
end
