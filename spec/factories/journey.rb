FactoryBot.define do
  factory :journey do
    started { false }
    state { :initial }

    association :user, factory: :user
    association :category, factory: :category

    # trait :additional_steps do
    #   # association { create(:section, :with_tasks, tasks_count: 5) }
    #   association(:section, count: 4)
    # end

    trait :with_sections do
      transient do
        section_count { 1 }
        tasks_per_section { 1 }
        steps_per_task { 1 }
      end

      sections do
        Array.new(section_count) { association(:section, :with_tasks, tasks_count: tasks_per_section) }
      end
    end

    factory :incomplete_journey do
      with_sections do
        section_count { 3 }
        tasks_per_section { 3 }
        steps_per_task { 2 }
      end
    end
  end
end
