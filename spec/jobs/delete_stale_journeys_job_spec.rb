require "rails_helper"

RSpec.describe DeleteStaleJourneysJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe ".perform_later" do
    it "enqueues a job asynchronously on the default queue" do
      expect {
        described_class.perform_later
      }.to have_enqueued_job.on_queue("default")
    end

    it "destroys all unstarted journeys" do
      more_than_one_month_ago = (1.month + 1.day).ago
      less_than_one_month_ago = (1.month - 1.day).ago

      legacy_journey = create(:journey, started: true, last_worked_on: nil)
      unstarted_journey = create(:journey, started: false, last_worked_on: more_than_one_month_ago)
      becoming_stale_journey = create(:journey, started: false, last_worked_on: less_than_one_month_ago)
      active_journey = create(:journey, started: true, last_worked_on: more_than_one_month_ago)

      described_class.perform_later
      perform_enqueued_jobs

      remaining_journeys = Journey.all
      expect(remaining_journeys).to include(legacy_journey)
      expect(remaining_journeys).to include(active_journey)
      expect(remaining_journeys).to include(becoming_stale_journey)
      expect(remaining_journeys).not_to include(unstarted_journey)
    end
  end
end
