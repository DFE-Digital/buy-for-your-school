FactoryBot.define do
  factory :task do
    title { "Task title" }
    contentful_id { "5m26U35YLau4cOaJq6FXZA" }
    order { 0 }
    association :section
    if ENV["RAILS_MIGRATION_PROD"] == "true"
      skipped_ids { [] }
    end

    trait :with_steps do
      transient do
        steps_count { 1 }
      end

      steps do
        Array.new(steps_count) { association(:step, :number) }
      end
    end
  end
end
