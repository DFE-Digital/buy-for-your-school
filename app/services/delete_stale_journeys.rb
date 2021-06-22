# DeleteStaleJourneys service performs a clean-up of {Journey}s that have not been started for over a month.
class DeleteStaleJourneys
  def call
    qualifying_journeys = Journey.where(started: false)
      .where("last_worked_on < ?", date_a_journey_can_be_inactive_until)
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
