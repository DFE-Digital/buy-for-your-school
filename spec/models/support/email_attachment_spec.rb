require "rails_helper"

RSpec.describe Support::EmailAttachment, type: :model do
  subject(:attachment) { build(:support_email_attachment) }

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

  describe ".for_case_attachments" do
    let(:attachment_to_hide) { create(:support_email_attachment).tap { |a| a.update(file_type: "application/bad-file") } }
    let(:attachment_to_show) { create(:support_email_attachment).tap { |a| a.update(file_type: CASE_ATTACHMENT_FILE_TYPE_ALLOW_LIST.first) } }

    it "queries for only attachments with file types within CASE_ATTACHMENT_FILE_TYPE_ALLOW_LIST" do
      results = described_class.for_case_attachments
      expect(results).to include(attachment_to_show)
      expect(results).not_to include(attachment_to_hide)
    end
  end
end
