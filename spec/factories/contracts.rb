FactoryBot.define do
  factory :contract do
    initialize_with { type.present? ? type.constantize.new : Contract.new }

    supplier { "MyString" }
    started_at { "2020-12-01" }
    ended_at { "2021-12-01" }
    duration { 12.months }
    spend { "9.99" }
  end
end
