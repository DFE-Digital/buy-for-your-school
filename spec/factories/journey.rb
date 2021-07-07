FactoryBot.define do
  factory :journey do
    started { true }
    state { :initial }

    association :user, factory: :user
    association :category, factory: :category
  end
end
