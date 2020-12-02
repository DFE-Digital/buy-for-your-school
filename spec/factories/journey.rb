FactoryBot.define do
  factory :journey do
    category { "catering" }
    next_entry_id { "47EI2X2T5EDTpJX9WjRR9p" }

    trait :catering do
      category { "catering" }
    end
  end
end
