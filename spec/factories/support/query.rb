FactoryBot.define do
  factory :support_query, class: "Support::Query" do
    sequence(:title) { |n| "support category title #{n}" }
  end
end
