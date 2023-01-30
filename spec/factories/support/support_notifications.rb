FactoryBot.define do
  factory :support_notification, class: "Support::Notification" do
    sequence(:body) { |n| "Basic notification #{n}" }
  end
end
