FactoryBot.define do
  factory :support_email_attachment, class: "Support::EmailAttachment" do
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/assets/support/email_attachments/attachment.txt"), "text/plain") }

    association :email, factory: :support_email

    trait :without_file do
      file { nil }
    end
  end
end
