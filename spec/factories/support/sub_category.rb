FactoryBot.define do
  factory :support_sub_category, class: "Support::SubCategory" do
    sequence(:title) { |n| "support sub category title #{n}" }
    sequence(:slug) { |n| "support sub category slug #{n}" }
    description { "support sub category description" }

    # association :category, factory: :support_category
  end
end
