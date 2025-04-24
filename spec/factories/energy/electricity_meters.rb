FactoryBot.define do
  factory :energy_electricity_meter, class: "Energy::ElectricityMeter" do
    energy_onboarding_case_organisation { nil }
    mpan { "MyString" }
  end
end
