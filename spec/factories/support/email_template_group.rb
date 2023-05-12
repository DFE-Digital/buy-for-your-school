FactoryBot.define do
  factory :support_email_template_group, class: "Support::EmailTemplateGroup" do
    sequence(:title) { |n| "Email Template Group #{n}" }
    parent { nil }
    archived { false }
    archived_at { nil }
  end
end
