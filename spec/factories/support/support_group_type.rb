FactoryBot.define do
  factory :support_group_type, class: "Support::GroupType" do
    sequence(:name) { |n| "name #{n}" }
    sequence(:code) { |n| n }
  end
end
