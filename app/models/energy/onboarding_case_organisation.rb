class Energy::OnboardingCaseOrganisation < ApplicationRecord
  belongs_to :onboarding_case, class_name: "Energy::OnboardingCase", foreign_key: "energy_onboarding_case_id"

  # An onboarding organisation can be one of:
  #   1. A single school         --> polymorphic association to Support::Organisation
  #   2. A school within a trust --> polymorphic association to Support::Organisation
  #   3. A trust itself          --> polymorphic association to Support::EstablishmentGroup
  belongs_to :onboardable, polymorphic: true

  has_many :gas_meters, class_name: "Energy::GasMeter", foreign_key: "energy_onboarding_case_organisation_id"
  has_many :electricity_meters, class_name: "Energy::ElectricityMeter", foreign_key: "energy_onboarding_case_organisation_id"
end
