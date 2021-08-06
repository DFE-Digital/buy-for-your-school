# Flag a {Journey} as stale that has not been started or edited for X days
#
# DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR=
class FlagStaleJourneys
  # Flip journey state and explicitly touch updated_at
  #
  # @return [Array<Journey>]
  #
  def call
    flagged = journeys.to_a # NB: to_a is required
    # NB: update_all returns the number of rows
    journeys.update_all(state: :stale, updated_at: Time.zone.now)
    flagged
  end

private

  # Unstarted and abandoned journeys
  #
  def journeys
    Journey.initial.not_started.unedited_since(grace_period)
  end

  # Defaults to 30 days
  #
  # @return [Date]
  def grace_period
    ENV.fetch("DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR", 30).to_i.days.ago
  end
end
