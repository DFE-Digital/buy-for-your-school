FactoryBot.define do
  factory :support_case_attachment, class: "Support::CaseAttachment" do
    association :case, factory: :support_case
    association :email_attachment, factory: :support_email_attachment
  end
end
