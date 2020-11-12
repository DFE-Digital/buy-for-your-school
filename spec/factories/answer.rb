FactoryBot.define do
  factory :answer do
    association :question, factory: :question

    response { "Green" }
  end
end
