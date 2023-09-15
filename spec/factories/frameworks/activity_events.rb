FactoryBot.define do
  factory :frameworks_activity_event, class: "Frameworks::ActivityEvent" do
    event { 1 }
    data { "" }
  end
end
