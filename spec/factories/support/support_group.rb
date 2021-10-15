FactoryBot.define do
  factory :support_group, class: "Support::Group" do
    sequence(:name) { |n| "name #{n}" }
    sequence(:code) { |n| n }
  end
end
