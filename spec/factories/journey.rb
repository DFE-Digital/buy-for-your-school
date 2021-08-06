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
  end
end
