FactoryBot.define do
  factory :support_email_template_attachment, class: "Support::EmailTemplateAttachment" do
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/assets/support/email_attachments/attachment.txt"), "text/plain") }

    association :template, factory: :support_email_template

    trait :without_file do
      file { nil }
    end
  end
end
