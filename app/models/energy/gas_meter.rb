class Energy::GasMeter < ApplicationRecord
  belongs_to :onboarding_case_organisation, class_name: "Energy::OnboardingCaseOrganisation",
                                            foreign_key: "energy_onboarding_case_organisation_id"

  validates :mprn,
            presence: true,
            format: { with: /\A[1-9][0-9]{5,11}\z/ }
  validates :gas_usage,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }
end
