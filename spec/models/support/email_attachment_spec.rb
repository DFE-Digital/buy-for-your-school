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

  describe ".import_attachment" do
    let(:email_attachment) { create(:support_email_attachment, outlook_id: "123") }
    let(:email) { email_attachment.email }

    let(:ms_attachment) do
      double(id: "123", content_bytes: "1024", name: "example_file.pdf")
    end

    context "when attachment has already been imported" do
      it "does not import again" do
        allow(email_attachment).to receive(:import_from_ms_attachment)

        described_class.import_attachment(ms_attachment, email)

        expect(email_attachment).not_to have_received(:import_from_ms_attachment)
      end
    end
  end

  describe "#import_from_ms_attachment" do
    let(:email_attachment) { build(:support_email_attachment, :without_file) }
    let(:ms_attachment) do
      double(id: "123", content_bytes: "SGVsbG8sIFdvcmxkCg==", name: "example_file.pdf", content_type: "text/plain", is_inline: true, content_id: "XYZ")
    end

    it "attaches file from temp file" do
      email_attachment.import_from_ms_attachment(ms_attachment)

      expect(email_attachment.file.download).to eq("Hello, World\n")
      expect(email_attachment.file_name).to eq("example_file.pdf")
      expect(email_attachment.content_id).to eq("XYZ")
      expect(email_attachment.is_inline).to be(true)
    end
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
