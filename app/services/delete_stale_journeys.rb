class DeleteStaleJourneys
  def call
    Journey.where(started: false)
      .where("last_worked_on > ?", 1.month.ago)
      .destroy_all
  end
end
