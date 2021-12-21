require "rails_helper"

describe Support::IncomingEmails::SharedMailbox do
  let(:graph_client) { double }

  describe ".synchronize" do
    let(:email_1) { double }
    let(:email_2) { double }

    before do
      allow_any_instance_of(described_class).to receive(:emails)
        .and_return([email_1, email_2])
    end

    it "converts each email into an Support::Email record" do
      allow(Support::Email).to receive(:from_message)

      described_class.synchronize

      expect(Support::Email).to have_received(:from_message).with(email_1).once
      expect(Support::Email).to have_received(:from_message).with(email_2).once
    end
  end

  describe "#emails" do
    subject(:mailbox) { described_class.new(graph_client: graph_client) }

    let(:graph_client) { double }
    let(:email) { double }

    before do
      stub_const("SHARED_MAILBOX_USER_ID", "1")
      stub_const("SHARED_MAILBOX_FOLDER_ID", "2")

      allow(graph_client).to receive(:list_messages_in_folder)
        .with(SHARED_MAILBOX_USER_ID, SHARED_MAILBOX_FOLDER_ID, query: anything)
        .and_return([email])
    end

    it "returns emails from the shared inbox" do
      expect(mailbox.emails).to eq([email])
    end

    context "when giving a custom date" do
      it "returns only emails sent at or after this date" do
        date = 1.week.ago

        mailbox.emails(since: date)

        expect(graph_client).to have_received(:list_messages_in_folder)
          .with(SHARED_MAILBOX_USER_ID, SHARED_MAILBOX_FOLDER_ID, query: [
            "$filter=sentDateTime ge #{date.utc.iso8601}",
            "$orderby=sentDateTime asc",
          ])
      end
    end
  end
end
