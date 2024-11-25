FactoryBot.define do
  factory :support_evaluator, class: "Support::Evaluator" do
    association :support_case
    first_name  { "first_name" }
    last_name   { "last_name" }
    sequence(:email) { |n| sprintf("test.%04d@example.com", n) }
  end
end
