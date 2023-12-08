FactoryBot.define do
  factory :email_attachment, class: "EmailAttachment" do
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/assets/support/email_attachments/attachment.txt"), "text/plain") }
    sequence(:outlook_id) { |n| n }

    association :email, factory: :support_email

    trait :without_file do
      file { nil }
    end
  end
end
