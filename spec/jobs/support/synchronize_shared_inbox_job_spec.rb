require "rails_helper"

describe Support::SynchronizeSharedInboxJob do
  subject(:job) { described_class.new }

  describe "#perform" do
    it "synchronizes emails from the last 15 minutes with the shared inbox" do
      allow(Support::IncomingEmails::SharedMailbox).to receive(:synchronize)

      job.perform

      expect(Support::IncomingEmails::SharedMailbox).to have_received(:synchronize)
        .with(emails_since: be_within(1.second).of(15.minutes.ago)).once
    end
  end
end
