FactoryBot.define do
  factory :timeline_stage, class: "Collaboration::TimelineStage" do
    state { :draft }
    stage { 0 }
    title { "Stage #{stage}" }
    complete_by { Date.parse("2024-05-20") }

    trait :published do
      state { :published }
    end

    trait :draft do
      state { :draft }
    end
  end
end
