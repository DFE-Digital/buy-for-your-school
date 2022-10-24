FactoryBot.define do
  factory :support_category, class: "Support::Category" do
    sequence(:title) { |n| "support category title #{n}" }
    sequence(:slug) { |n| "support category slug #{n}" }
    parent { nil }
    description { "support category description" }
    association :tower, factory: :support_tower

    transient do
      with_tower { nil }
    end

    after(:create) do |category, evaluator|
      if evaluator.with_tower.present?
        category.tower = Support::Tower.find_or_create_by(title: evaluator.with_tower)
        category.save!
      end
    end

    trait :with_sub_category do
      after(:create) do |parent|
        create(:support_category, title: "Catering", parent_id: parent.id)
        parent.reload
      end
    end

    trait :fixed_title do
      title { "Example Category" }
    end
  end
end
