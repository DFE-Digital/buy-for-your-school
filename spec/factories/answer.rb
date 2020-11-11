FactoryBot.define do
  factory :answer do
    association :question, factory: :question
  factory :radio_answer do
    association :question, factory: :question, contentful_type: "radios"

    response { "Green" }
  end

    response { "Green" }
  end
end
