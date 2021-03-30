class DeleteStaleJourneys
  def call
    qualifying_journeys = Journey.where(started: false)
      .where("last_worked_on < ?", 1.month.ago)
    qualifying_journeys.destroy_all
  end
  end
end
