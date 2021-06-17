FactoryBot.define do
  factory :task do
    title { "Task title" }
    contentful_id { "5m26U35YLau4cOaJq6FXZA" }
    association :section

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
