FactoryBot.define do
  factory :timeline_task, class: "Collaboration::TimelineTask" do
    state { :draft }
    title { "Task" }
    start_date { Date.parse("2024-05-01") }
    end_date { Date.parse("2024-05-22") }
    duration { start_date.business_days_until(end_date).days }

    trait :published do
      state { :published }
    end

    trait :draft do
      state { :draft }
    end
  end
end
