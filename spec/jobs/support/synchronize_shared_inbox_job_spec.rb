require "rails_helper"

describe Support::SynchronizeSharedInboxJob do
  subject(:job) { described_class.new }

  describe "#perform" do
    before do
      stub_const("SHARED_MAILBOX_FOLDER_ID_INBOX", "2")
      stub_const("SHARED_MAILBOX_FOLDER_ID_SENT_ITEMS", "2")
    end

    it "synchronizes emails from the last 15 minutes with the shared mailbox inbox folder" do
      allow(Support::IncomingEmails::SharedMailbox).to receive(:synchronize)

      job.perform

      expect(Support::IncomingEmails::SharedMailbox).to have_received(:synchronize)
        .with(emails_since: be_within(1.second).of(15.minutes.ago), folder: :inbox).once
    end

    it "synchronizes emails from the last 15 minutes with the shared mailbox sent messages folder" do
      allow(Support::IncomingEmails::SharedMailbox).to receive(:synchronize)

      job.perform

      expect(Support::IncomingEmails::SharedMailbox).to have_received(:synchronize)
        .with(emails_since: be_within(1.second).of(15.minutes.ago), folder: :sent_items).once
    end
  end
end
