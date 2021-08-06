RSpec.describe FlagStaleJourneysJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  around do |example|
    # NB: remove this when flagging stale journeys is approved
    ClimateControl.modify(FLAG_STALE_JOURNEYS: "true") do
      example.run
    end
  end

  describe ".perform_later" do
    it "enqueues a job asynchronously on the default queue" do
      expect { described_class.perform_later }.to have_enqueued_job.on_queue("default")
    end

    it "flags journeys as stale after a grace period" do
      before_grace_period = create(:journey, state: :initial, started: false, updated_at: 29.days.ago)
      after_grace_period = create(:journey, state: :initial, started: false, updated_at: 31.days.ago)

      expect(Rollbar).to receive(:info).with("Flagged 1 journeys as stale.")

      described_class.perform_later
      perform_enqueued_jobs

      stale_journeys = Journey.stale

      expect(stale_journeys).to include after_grace_period
      expect(stale_journeys).not_to include before_grace_period
    end
  end
end
