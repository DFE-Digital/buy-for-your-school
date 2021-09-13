FactoryBot.define do
  factory :support_request do
    message { "Support request message from a School Buying Professional" }
    phone_number { "0151 000 0000" }
    association :user
    association :journey, factory: %i[journey with_sections]
    association :category
  end
end
