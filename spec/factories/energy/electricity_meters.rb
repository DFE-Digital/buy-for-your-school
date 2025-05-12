FactoryBot.define do
  factory :energy_electricity_meter, class: "Energy::ElectricityMeter" do
    energy_onboarding_case_organisation { nil }
    mpan { "1234512345123" }
    is_half_hourly { false }
    electricity_usage { 1000 }
  end
end
