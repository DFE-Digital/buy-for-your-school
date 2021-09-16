FactoryBot.define do
  factory :section do
    title { "Section title" }
    contentful_id { "5m26U35YLau4cOaJq6FXZA" }
    association :journey
    order { 0 }

    trait :with_tasks do
      transient do
        tasks_count { 1 }
      end

      tasks do
        Array.new(tasks_count) { association(:task) }
      end
    end

    trait :with_steps do
      transient do
        tasks_count { 1 }
      end

      tasks do
        Array.new(tasks_count) { association(:task, :with_steps) }
      end
    end
  end
end
