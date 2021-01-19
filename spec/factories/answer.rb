FactoryBot.define do
  factory :radio_answer do
    association :step, factory: :step, contentful_type: "radios", contentful_model: "question"

    response { "Green" }
    further_information { nil }
  end

  factory :short_text_answer do
    association :step, factory: :step, contentful_type: "short_text", contentful_model: "question"

    response { "Green" }
  end

  factory :long_text_answer do
    association :step, factory: :step, contentful_type: "long_text", contentful_model: "question"

    response { "Lots of green" }
  end

  factory :single_date_answer do
    association :step, factory: :step, contentful_type: "single_date", contentful_model: "question"

    response { 1.year.from_now }
  end

  factory :checkbox_answers do
    association :step, factory: :step, options: [{"value" => "Breakfast"}, {"value" => "Lunch"}], contentful_type: "checkboxes", contentful_model: "question"

    response { ["breakfast", "lunch", ""] }
  end
end
