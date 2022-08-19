require "rails_helper"

describe Support::Messages::Outlook::Message do
  def mock_recipient(num = 1)
    double(email_address: double(address: "email#{num}@address.com", name: "Sender #{num}"))
  end

  describe "#sender" do
    subject(:message) { described_class.new(double(from: mock_recipient)) }

    it "returns the sender information in a simpler format for persisting" do
      expect(message.sender).to eq({ address: "email1@address.com", name: "Sender 1" })
    end
  end

  describe "#recipients" do
    subject(:message) { described_class.new(double(to_recipients: Array.new(3) { |i| mock_recipient(i + 1) }, cc_recipients: [mock_recipient(4)], bcc_recipients: [mock_recipient(5)])) }

    it "returns the recipients information in a simpler format for persisting" do
      expect(message.recipients).to eq([
        { address: "email1@address.com", name: "Sender 1" },
        { address: "email2@address.com", name: "Sender 2" },
        { address: "email3@address.com", name: "Sender 3" },
        { address: "email4@address.com", name: "Sender 4" },
        { address: "email5@address.com", name: "Sender 5" },
      ])
    end
  end

  describe "#attachments" do
    subject(:message) { described_class.from_resource(double(id: "MESSAGEID"), mail_folder: double("mail_folder"), ms_graph_client:) }

    let(:ms_graph_client) { double("ms_graph_client") }
    let(:result1) { double("result1") }
    let(:result2) { double("result2") }

    before do
      allow(ms_graph_client).to receive(:get_file_attachments).and_return([result1, result2])
    end

    it "calls the api for attachments for the given message" do
      message.attachments
      expect(ms_graph_client).to have_received(:get_file_attachments).with(SHARED_MAILBOX_USER_ID, message.id)
    end

    it "returns each attachment decordated as a MessageAttachment" do
      expect(message.attachments).to eq([
        Support::Messages::Outlook::MessageAttachment.new(result1),
        Support::Messages::Outlook::MessageAttachment.new(result2),
      ])
    end
  end
end
