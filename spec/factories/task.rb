FactoryBot.define do
  factory :task do
    title { "Task title" }
    contentful_id { "5m26U35YLau4cOaJq6FXZA" }
    association :section
  end
end
