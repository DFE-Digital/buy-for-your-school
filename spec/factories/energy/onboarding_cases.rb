FactoryBot.define do
  factory :onboarding_case, class: "Energy::OnboardingCase" do
    association :support_case
    are_you_authorised { true }

    trait :submitted do
      submitted_at { Time.zone.now }
    end
  end
end
