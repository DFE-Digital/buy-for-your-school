class Energy::OnboardingCaseOrganisation < ApplicationRecord
  belongs_to :onboarding_case, class_name: "Energy::OnboardingCase", foreign_key: "energy_onboarding_case_id"

  # An onboarding organisation can be one of:
  #   1. A single school         --> polymorphic association to Support::Organisation
  #   2. A school within a trust --> polymorphic association to Support::Organisation
  #   3. A trust itself          --> polymorphic association to Support::EstablishmentGroup
  belongs_to :onboardable, polymorphic: true

  has_many :gas_meters, class_name: "Energy::GasMeter", foreign_key: "energy_onboarding_case_organisation_id"
  has_many :electricity_meters, class_name: "Energy::ElectricityMeter", foreign_key: "energy_onboarding_case_organisation_id"

  # Energy type
  #   electricity       - Electricity only
  #   gas               - Gas only
  #   electricity_gas   - Gas and electricity
  enum :switching_energy_type, { electricity: 0, gas: 1, gas_electricity: 2 }, prefix: true

  # Current suppliers
  #
  #   british_gas     - British Gas
  #   edf_energy      - EDF Energy
  #   eon_next        - E.ON Next
  #   scottish_power   - Scottish Power
  #   ovo_energy      - OVO Energy
  #   octopus_energy  - Octopus Energy
  #   other           - Other

  CURRENT_SUPPLIERS = {
    british_gas: 0,
    edf_energy: 1,
    eon_next: 2,
    scottish_power: 3,
    ovo_energy: 4,
    octopus_energy: 5,
    other: 6,
  }.freeze

  enum :gas_current_supplier, CURRENT_SUPPLIERS, prefix: true
  enum :electric_current_supplier, CURRENT_SUPPLIERS, prefix: true

  GAS_SINGLE_MULTI = {
    single: 0,
    multi: 1,
  }.freeze

  enum :gas_single_multi, GAS_SINGLE_MULTI, prefix: true

  ELECTRICITY_SINGLE_MULTI = {
    single: 0,
    multi: 1,
  }.freeze

  # Electricity meter type type
  #   single  - Single meter
  #   multi   - Multi meter
  enum :electricity_meter_type, ELECTRICITY_SINGLE_MULTI, prefix: true

  BILLING_PAYMENT_METHOD = {
    bacs: 0,
    direct_debit: 1,
    gov_procurement_card: 2,
  }.freeze

  BILLING_PAYMENT_TERMS = {
    days14: 0,
    days21: 1,
    days28: 2,
    days30: 3,
  }.freeze

  BILLING_INVOICING_METHOD = {
    email: 0,
    paper: 1,
  }.freeze

  enum :billing_payment_method, BILLING_PAYMENT_METHOD, prefix: true
  enum :billing_payment_terms, BILLING_PAYMENT_TERMS, prefix: true
  enum :billing_invoicing_method, BILLING_INVOICING_METHOD, prefix: true
end
