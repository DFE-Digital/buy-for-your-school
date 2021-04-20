class DeleteStaleJourneys
  def call
    binding.pry
    qualifying_journeys = Journey.where(started: false)
      .where("last_worked_on < ?", date_a_journey_can_be_inactive_until)
    qualifying_journeys.destroy_all
  end

  private def date_a_journey_can_be_inactive_until
    return 1.month.ago unless ENV["DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR"].present?

    day_count = ENV["DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR"].to_i
    day_count.days.ago
  end
end
