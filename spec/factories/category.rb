FactoryBot.define do
  factory :category do
    title { "Catering" }
    contentful_id { "12345678" }
    liquid_template { "Your answer was {{ answer_47EI2X2T5EDTpJX9WjRR9p }}" }

    trait :catering do
      title { "Catering" }
    end
  end
end
