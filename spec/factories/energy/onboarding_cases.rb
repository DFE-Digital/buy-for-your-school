FactoryBot.define do
  factory :energy_onboarding_case, class: "Energy::OnboardingCase" do
    support_case_id { nil }
    are_you_authorised { false }
  end
end
