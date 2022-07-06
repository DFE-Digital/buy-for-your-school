FactoryBot.define do
  factory :activity_log_item do
    sequence(:contentful_category_id) { |n| n }
    sequence(:contentful_section_id) { |n| n }
    sequence(:contentful_task_id) { |n| n }
    sequence(:contentful_step_id) { |n| n }
    contentful_category { nil }
    contentful_section { nil }
    contentful_task { nil }
    contentful_step { nil }
    action { "save_answer" }

    association :category, factory: :category
    association :section, factory: :section
    association :step, factory: :step
    association :task, factory: :task
    association :user, factory: :user
    association :journey, factory: :journey
  end
end
