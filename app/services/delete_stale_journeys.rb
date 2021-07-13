# Perform purge of {Journey}s that have not been started.
# Defaults to a one month grace period.
#
# @example
#   DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR=60
#
class DeleteStaleJourneys
  # TODO: move qualifying_journeys method to the Journey model
  def call
    qualifying_journeys = Journey.where(started: false)
      .where("updated_at < ?", date_a_journey_can_be_inactive_until)
    qualifying_journeys.destroy_all
  end

private

  # @return [Date]
  def date_a_journey_can_be_inactive_until
    return 1.month.ago if ENV["DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR"].blank?

    day_count = ENV["DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR"].to_i
    day_count.days.ago
  end
end
