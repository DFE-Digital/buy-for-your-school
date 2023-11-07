require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::MessageAttachmentImporter do
  let(:email)               { create(:support_email) }
  let(:message)             { double(id: "123", name: "hello.txt", is_inline: true, content_type: "text/plain", content_id: "123", content_bytes: Base64.encode64("Hello, World\n")) }
  let(:message_attachment)  { Support::Messages::Outlook::MessageAttachment.new(message) }

  context "when the email attachment has already been imported" do
    let!(:existing_email_attachment) { create(:support_email_attachment, email:, outlook_id: "123") }

    it "does not import the attachment again" do
      expect { described_class.call(message_attachment, email) }.not_to(change { existing_email_attachment.reload.attributes })
    end
  end

  context "when the email attachment has not been updated" do
    it "attaches the file contents to the email" do
      described_class.call(message_attachment, email)

      email_attachment = email.attachments.first

      expect(email_attachment.file.download).to eq("Hello, World\n")
      expect(email_attachment.is_inline).to eq(true)
      expect(email_attachment.content_id).to eq("123")
      expect(email_attachment.file_type).to eq("text/plain")
      expect(email_attachment.file_name).to eq("hello.txt")
      expect(email_attachment.file_size).to eq(13)
    end
  end
end
