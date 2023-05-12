FactoryBot.define do
  factory :support_email_template, class: "Support::EmailTemplate" do
    sequence(:title) { |n| "Email Template #{n}" }
    description { "This is a test email template" }
    stage { 0 }
    subject { "Test email template subject" }
    body { "Test email template body" }
    archived { false }
    archived_at { nil }

    association :group, factory: :support_email_template_group
    association :created_by, factory: :support_agent
    association :updated_by, factory: :support_agent
  end
end
