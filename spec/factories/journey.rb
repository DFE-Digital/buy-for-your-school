FactoryBot.define do
  factory :journey do
    started { false }
    state { :initial }
    name { "test spec" }

    association :user, factory: :user
    association :category, factory: :category

    trait :with_sections do
      transient do
        sections_count { 1 }
      end

      sections do
        Array.new(sections_count) { association(:section) }
      end
    end

    trait :with_steps do
      transient do
        sections_count { 1 }
        with_steps { false }
      end

      sections do
        Array.new(sections_count) { association(:section, :with_steps) }
      end
    end
  end
end
