FactoryBot.define do
  factory :task do
    title { "Task title" }
    contentful_id { "1pllr2bjzuv9isebwweekq" }
    association :section
  end
end
