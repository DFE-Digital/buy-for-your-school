FactoryBot.define do
  factory :energy_gas_meter, class: "Energy::GasMeter" do
    energy_onboarding_case_organisation { nil }
    mprn { "123456" }
    gas_usage { 1000 }
  end
end
