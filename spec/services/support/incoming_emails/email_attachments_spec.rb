describe Support::IncomingEmails::EmailAttachments do
  let(:graph_client) { double }
  let(:email) { create(:support_email) }

  describe ".download" do
    let(:attachment_1) { double }
    let(:attachment_2) { double }

    before do
      allow_any_instance_of(described_class).to receive(:for_message).and_return([attachment_1, attachment_2])
    end

    it "converts each attachment into a Support::Attachment record" do
      allow(Support::EmailAttachment).to receive(:import_attachment)

      described_class.download(email: email)

      expect(Support::EmailAttachment).to have_received(:import_attachment).with(attachment_1, email).once
      expect(Support::EmailAttachment).to have_received(:import_attachment).with(attachment_2, email).once
    end
  end
end
