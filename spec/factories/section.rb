FactoryBot.define do
  factory :section do
    title { "Section title" }
    contentful_id { "5m26U35YLau4cOaJq6FXZA" }
    association :journey
  end
end
