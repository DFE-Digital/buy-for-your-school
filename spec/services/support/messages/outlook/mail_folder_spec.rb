require "rails_helper"

describe Support::Messages::Outlook::MailFolder do
  describe "#inbox?" do
    context "when folder is inbox" do
      subject(:mail_folder) { described_class.new(folder: :inbox) }

      it "returns true" do
        expect(mail_folder.inbox?).to be(true)
      end
    end

    context "when folder is sent_items" do
      subject(:mail_folder) { described_class.new(folder: :sent_items) }

      it "returns false" do
        expect(mail_folder.inbox?).to be(false)
      end
    end
  end

  describe "#recent_messages" do
    subject(:mail_folder)  { described_class.new(folder: :inbox, ms_graph_client:) }

    let(:messages_after)   { 15.minutes.ago }
    let(:ms_graph_client)  { double("ms_graph_client") }
    let(:result1)          { double("ms_graph_client_result1") }
    let(:result2)          { double("ms_graph_client_result2") }

    before do
      allow(ms_graph_client).to receive(:list_messages_in_folder).and_return([result1, result2])
    end

    it "filters messages by sent date time" do
      mail_folder.recent_messages
      expect(ms_graph_client).to have_received(:list_messages_in_folder).with(
        SHARED_MAILBOX_USER_ID,
        "Inbox",
        query: ["$filter=sentDateTime ge #{messages_after.utc.iso8601}", "$orderby=sentDateTime asc"],
      )
    end
  end
end
