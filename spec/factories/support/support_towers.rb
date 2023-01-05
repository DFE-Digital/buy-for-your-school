FactoryBot.define do
  factory :support_tower, class: "Support::Tower" do
    sequence(:title) { |n| "support tower #{n}" }
  end
end
