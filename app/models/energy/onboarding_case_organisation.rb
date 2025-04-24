class Energy::OnboardingCaseOrganisation < ApplicationRecord
  belongs_to :onboarding_case, class_name: "Energy::OnboardingCase", foreign_key: "energy_onboarding_case_id"
  belongs_to :support_case_organisation, class_name: "Support::CaseOrganisation", optional: true
  belongs_to :support_organisation, class_name: "Support::Organisation", optional: true
  belongs_to :support_establishment_group, class_name: "Support::EstablishmentGroup", optional: true
  has_many :gas_meters, class_name: "Energy::GasMeter", foreign_key: "energy_onboarding_case_organisation_id"
  has_many :electricity_meters, class_name: "Energy::ElectricityMeter", foreign_key: "energy_onboarding_case_organisation_id"
end
