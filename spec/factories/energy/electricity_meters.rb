FactoryBot.define do
  factory :energy_electricity_meter, class: "Energy::ElectricityMeter" do
    onboarding_case_organisation { nil }
    mpan { "MyString" }
    trait :with_valid_data do
      mpan { "1234512345123" }
      is_half_hourly { false }
      electricity_usage { 1000 }
    end

    trait :another_meter do
      mpan { rand.to_s[2..14] }
      is_half_hourly { false }
      electricity_usage { 1000 }
      supply_capacity { 100 }
    end
  end
end
