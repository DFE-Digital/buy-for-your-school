FactoryBot.define do
  factory :support_sub_category, class: "Support::SubCategory" do
    title { "support sub category title" }
    slug { "support sub category slug" }
    description { "support sub category description" }

    # association :category, factory: :support_category
  end
end
