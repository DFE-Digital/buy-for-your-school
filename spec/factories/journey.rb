FactoryBot.define do
  factory :journey do
    category { "catering" }
    liquid_template { "Your answer was {{ answer_47EI2X2T5EDTpJX9WjRR9p }}" }
    section_groups { [] }

    trait :catering do
      category { "catering" }
    end
  end
end
