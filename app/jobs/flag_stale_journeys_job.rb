class FlagStaleJourneysJob < ApplicationJob
  queue_as :default

  def perform
    return unless ENV["FLAG_STALE_JOURNEYS"] # no-op until approval received

    journeys = FlagStaleJourneys.new.call

    # TODO: add journey/user params to the Rollbar payload
    Rollbar.info("Flagged #{journeys.size} journeys as stale.")
  end
end
