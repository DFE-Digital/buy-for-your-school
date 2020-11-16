FactoryBot.define do
  factory :answer do
    association :question, factory: :question, contentful_type: "radios"

    response { "Green" }
  end

  factory :radio_answer do
    association :question, factory: :question, contentful_type: "radios"

    response { "Green" }
  end

  factory :short_text_answer do
    association :question, factory: :question, contentful_type: "short_text"

    response { "Green" }
  end
end
