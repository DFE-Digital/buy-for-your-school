FactoryBot.define do
  factory :radio_answer do
    association :step, factory: :step, contentful_type: "radios"

    response { "Green" }
  end

  factory :short_text_answer do
    association :step, factory: :step, contentful_type: "short_text"

    response { "Green" }
  end

  factory :long_text_answer do
    association :step, factory: :step, contentful_type: "long_text"

    response { "Lots of green" }
  end
end
