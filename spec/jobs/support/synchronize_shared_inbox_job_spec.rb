require "rails_helper"

describe Support::SynchronizeSharedInboxJob do
  subject(:job) { described_class.new }

  describe "#perform" do
    it "synchronizes emails from the last 15 minutes with the shared inbox" do
      mailbox = double(synchronize: nil)
      allow(Support::IncomingEmails::SharedMailbox).to receive(:new).and_return(mailbox)

      job.perform

      expect(mailbox).to have_received(:synchronize).with(emails_since: be_within(1.second).of(15.minutes.ago)).once
    end
  end
end
