FactoryBot.define do
  factory :support_request do
    message_body { "Support request message from a School Buying Professional" }
    phone_number { "07756471233" }
    procurement_amount { "10.50" }
    confidence_level { "confident" }
    special_requirements { "special_requirements" }
    association :user
    association :category

    trait :with_specification do
      association :journey, factory: %i[journey with_steps]
    end
  end
end
