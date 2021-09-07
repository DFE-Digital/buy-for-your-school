FactoryBot.define do
  factory :support_request do
    message { "Support request message from a School Buying Professional" }
    association :user
    association :journey
    association :category
  end
end
