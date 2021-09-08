FactoryBot.define do
  factory :support_category, class: "Support::Category" do
    title { "support category title" }
    slug { "support category slug" }
    description { "support category description" }

    # association :category, factory: :support_sub_category
  end
end
