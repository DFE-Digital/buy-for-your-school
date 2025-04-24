class Energy::OnboardingCaseOrganisation < ApplicationRecord
  belongs_to :onboarding_case, class_name: "Energy::OnboardingCase", foreign_key: "energy_onboarding_case_id"

  # An onboarding organisation can be one of:
  #   1. A single school
  #   2. A school within a trust
  #   3. A trust itself
  # hence these 3 foreign keys, they're all 1:1 relations
  #
  # This could be a polymorphic relation but I'm keeping it plain until we've
  # fully nailed down the data structure
  #
  # We should probably add an 'organisation_type' attribute to indicate what it is
  belongs_to :support_organisation, class_name: "Support::Organisation", optional: true # if single school
  belongs_to :support_case_organisation, class_name: "Support::CaseOrganisation", optional: true # if a school within a trust
  belongs_to :support_establishment_group, class_name: "Support::EstablishmentGroup", optional: true # if a trust itself

  has_many :gas_meters, class_name: "Energy::GasMeter", foreign_key: "energy_onboarding_case_organisation_id"
  has_many :electricity_meters, class_name: "Energy::ElectricityMeter", foreign_key: "energy_onboarding_case_organisation_id"
end
