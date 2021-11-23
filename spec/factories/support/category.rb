FactoryBot.define do
  factory :support_category, class: "Support::Category" do
    sequence(:title) { |n| "support category title #{n}" }
    sequence(:slug) { |n| "support category slug #{n}" }
    parent { nil }
    description { "support category description" }

    trait :with_sub_category do

      after(:create) do |parent|
        create(:support_category, parent_id: parent.id)
        parent.reload
      end
    end
  end
end
