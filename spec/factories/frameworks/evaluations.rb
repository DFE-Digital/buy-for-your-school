FactoryBot.define do
  factory :frameworks_evaluation, class: "Frameworks::Evaluation" do
    reference { "MyString" }
    framework_id { "" }
    status { 1 }
  end
end
