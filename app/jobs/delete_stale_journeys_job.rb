class DeleteStaleJourneysJob < ApplicationJob
  queue_as :default

  def perform
    return unless ENV["DELETE_STALE_JOURNEYS"] # no-op until approval received

    journeys = DeleteStaleJourneys.new.call

    Rollbar.info("Deleted #{journeys.size} stale journeys.")
  end
end
