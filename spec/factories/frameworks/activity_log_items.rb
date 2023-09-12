FactoryBot.define do
  factory :frameworks_activity_log_item, class: "Frameworks::ActivityLogItem" do
    actor_id { "" }
    actor_type { "MyString" }
    activity_id { "" }
    activity_type { "MyString" }
    subject_id { "" }
    subject_type { "MyString" }
  end
end
