FactoryBot.define do
  factory :energy_gas_meter, class: "Energy::GasMeter" do
    onboarding_case_organisation { nil }
    mprn { "MyString" }
    trait :with_valid_data do
      mprn { "123456" }
      gas_usage { 1000 }
    end
  end
end
