RSpec.describe DeleteStaleJourneysJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  around do |example|
    # NB: remove this when deletion of stale journeys is approved
    ClimateControl.modify(DELETE_STALE_JOURNEYS: "true") do
      example.run
    end
  end

  describe ".perform_later" do
    it "enqueues a job asynchronously on the default queue" do
      expect { described_class.perform_later }.to have_enqueued_job.on_queue("default")
    end

    it "destroys all stale journeys after a grace period" do
      before_grace_period = create(:journey, state: :stale, started: false, updated_at: 29.days.ago)
      after_grace_period = create(:journey, state: :stale, started: false, updated_at: 31.days.ago)

      expect(Rollbar).to receive(:info).with("Deleted 1 stale journeys.")

      described_class.perform_later
      perform_enqueued_jobs

      remaining_journeys = Journey.all

      expect(remaining_journeys).to include before_grace_period
      expect(remaining_journeys).not_to include after_grace_period
    end
  end
end
