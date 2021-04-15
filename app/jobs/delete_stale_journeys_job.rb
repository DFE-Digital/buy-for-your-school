class DeleteStaleJourneysJob < ApplicationJob
  queue_as :default

  def perform
    DeleteStaleJourneys.new.call

    Rollbar.info("Delete stale journeys task complete.")
  end
end
