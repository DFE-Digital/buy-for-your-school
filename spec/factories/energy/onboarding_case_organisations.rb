FactoryBot.define do
  factory :energy_onboarding_case_organisation, class: "Energy::OnboardingCaseOrganisation" do
    association :onboarding_case, factory: :onboarding_case
    association :onboardable, factory: :support_organisation
    switching_energy_type { 0 }

    trait :with_energy_details do
      switching_energy_type { 2 }
      gas_current_supplier { :british_gas }
      gas_current_contract_end_date { Date.new(2025, 10, 31) }
      electric_current_supplier { :edf_energy }
      electric_current_contract_end_date { Date.new(2025, 11, 30) }
      gas_bill_consolidation { true }
      electricity_meter_type { 1 }
      is_electric_bill_consolidated { false }
      site_contact_email { "ned@kelly.com" }
      site_contact_phone { "07777123123" }
    end
  end
end
