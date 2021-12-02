FactoryBot.define do
  factory :contract do
    supplier { "MyString" }
    started_at { "2020-12-01" }
    ended_at { "2021-12-01" }
    duration { 12.months }
    spend { "9.99" }
  end
end
