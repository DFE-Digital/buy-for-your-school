FactoryBot.define do
  factory :step do
    title { "What is your favourite colour?" }
    help_text { "Choose the primary colour closest to your choice" }
    raw { {"sys": {"id" => "123"}} }
    contentful_id { "123" }

    association :journey, factory: :journey

    trait :radio do
      options { [{"value" => "Red"}, {"value" => "Green"}, {"value" => "Blue"}] }
      contentful_model { "question" }
      contentful_type { "radios" }
    end

    trait :short_text do
      options { nil }
      contentful_model { "question" }
      contentful_type { "short_text" }
    end

    trait :long_text do
      options { nil }
      contentful_model { "question" }
      contentful_type { "long_text" }
    end

    trait :single_date do
      options { nil }
      contentful_model { "question" }
      contentful_type { "single_date" }
    end

    trait :checkbox_answers do
      options { [{"value" => "Brown"}, {"value" => "Gold"}] }
      contentful_model { "question" }
      contentful_type { "checkboxes" }
    end

    trait :number do
      options { nil }
      contentful_model { "question" }
      contentful_type { "number" }
    end

    trait :static_content do
      options { nil }
      contentful_model { "staticContent" }
      contentful_type { "paragraphs" }
    end
  end
end
