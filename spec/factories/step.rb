FactoryBot.define do
  factory :step do
    title { "What is your favourite colour?" }
    help_text { "Choose the primary colour closest to your choice" }
    raw { "{\"sys\":{}}" }

    association :journey, factory: :journey

    trait :radio do
      options { ["Red", "Green", "Blue"] }
      contentful_model { "question" }
      contentful_type { "radios" }
      association :radio_answer
    end

    trait :short_text do
      options { nil }
      contentful_model { "question" }
      contentful_type { "short_text" }
      association :short_text_answer
    end

    trait :long_text do
      options { nil }
      contentful_model { "question" }
      contentful_type { "long_text" }
      association :long_text_answer
    end
  end
end
