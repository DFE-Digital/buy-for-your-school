require "rails_helper"

describe Support::EmailTemplateAttachment, type: :model do
  subject(:attachment) { build(:support_email_template_attachment) }

  it { is_expected.to belong_to(:template).class_name("Support::EmailTemplate").optional(true) }

  it "updates the file_name attribute to match the file name" do
    attachment.save!

    expect(attachment.file_name).to eq("attachment.txt")
  end

  it "updates the file_type attribute to match the file type" do
    attachment.save!

    expect(attachment.file_type).to eq("text/plain")
  end

  it "updates the file_size attribute to match the file size" do
    attachment.save!

    expect(attachment.file_size).to eq(35)
  end
end
