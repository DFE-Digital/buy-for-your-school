FactoryBot.define do
  factory :support_request do
    message_body { "Support request message from a School Buying Professional" }
    phone_number { "0151 000 0000" }
    association :user
    association :category

    trait :with_specification do
      association :journey, factory: %i[journey with_steps]
    end
  end
end
