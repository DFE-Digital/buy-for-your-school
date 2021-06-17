FactoryBot.define do
  factory :journey do
    category { "catering" }
    contentful_id { "12345678" }
    liquid_template { "Your answer was {{ answer_47EI2X2T5EDTpJX9WjRR9p }}" }
    started { true }
    last_worked_on { Time.zone.now }

    association :user, factory: :user

    trait :catering do
      category { "catering" }
    end
  end
end
