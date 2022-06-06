require "rails_helper"

describe Support::ResyncEmailIdsJob do
  subject(:job) { described_class.new }

  describe "#perform" do
    it "synchronizes emails outlook ids from the last 15 minutes (all mail folders)" do
      resync = double("resync_service", call: nil)
      allow(Support::Messages::Outlook::ResyncEmailIds).to receive(:new)
        .with(messages_updated_after: within(1.second).of(15.minutes.ago))
        .and_return(resync)

      job.perform

      expect(resync).to have_received(:call).once
    end
  end
end
