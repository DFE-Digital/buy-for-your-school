require "rails_helper"

describe Support::Messages::Outlook::Synchronisation::Steps::PersistEmailAttachments do
  let(:attachment_1) { double("attachment_1") }
  let(:attachment_2) { double("attachment_2") }
  let(:email)        { double("email") }

  before do
    allow(Support::Messages::Outlook::Synchronisation::MessageAttachmentImporter)
      .to receive(:call).with(attachment_1, email)
      .and_return(nil)

    allow(Support::Messages::Outlook::Synchronisation::MessageAttachmentImporter)
      .to receive(:call).with(attachment_2, email)
      .and_return(nil)
  end

  context "when there are attachments on the message" do
    let(:message) { double("message-with-attachments", attachments: [attachment_1, attachment_2]) }

    it "imports each attachment on the message" do
      described_class.call(message, email)

      expect(Support::Messages::Outlook::Synchronisation::MessageAttachmentImporter)
        .to have_received(:call).with(attachment_1, email).once
      expect(Support::Messages::Outlook::Synchronisation::MessageAttachmentImporter)
        .to have_received(:call).with(attachment_2, email).once
    end
  end

  context "when there are no attachments on the message" do
    let(:message) { double("message-without-attachments", attachments: []) }

    it "does not improt anything" do
      described_class.call(message, email)

      expect(Support::Messages::Outlook::Synchronisation::MessageAttachmentImporter)
        .not_to have_received(:call)
    end
  end
end
