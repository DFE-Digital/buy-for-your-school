FactoryBot.define do
  factory :timeline, class: "Collaboration::Timeline" do
    state { :draft }
    start_date { Date.parse("2024-05-01") }
    end_date { Date.parse("2024-05-22") }

    trait :published do
      state { :published }
    end

    trait :draft do
      state { :draft }
    end
  end
end
