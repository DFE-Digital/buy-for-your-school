FactoryBot.define do
  factory :question do
    title { "What is your favourite colour?" }
    help_text { "Choose the primary colour closest to your choice" }
    association :plan, factory: :plan

    trait :radio do
      options { ["Red", "Green", "Blue"] }
      contentful_type { "radios" }
    end
  end
end
