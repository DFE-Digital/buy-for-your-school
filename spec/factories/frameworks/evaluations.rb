FactoryBot.define do
  factory :frameworks_evaluation, class: "Frameworks::Evaluation" do
    reference { "MyString" }
    framework_id { "" }
    status { 1 }

    association :framework, factory: :frameworks_framework
    association :assignee, factory: :support_agent
  end
end
