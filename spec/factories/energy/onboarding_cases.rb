FactoryBot.define do
  factory :onboarding_case, class: "Energy::OnboardingCase" do
    association :support_case
    are_you_authorised { true }
  end
end
