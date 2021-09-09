FactoryBot.define do
  factory :support_category, class: "Support::Category" do
    sequence(:title) { |n| "support category title #{n}" }
    sequence(:slug) { |n| "support category slug #{n}" }
    description { "support category description" }

    # association :category, factory: :support_sub_category
  end
end
