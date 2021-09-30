# Purge a {Journey} that has not been started or edited for X days
#
class DeleteStaleJourneys
  # @return [Array<Journey>]
  #
  def call
    journeys.destroy_all
  end

private

  # Journeys that were marked as stale and still untouched after 30 days
  #
  def journeys
    Journey.stale.not_started.unedited_since(grace_period)
  end

  # Defaults to 30 days
  #
  # @return [Date]
  def grace_period
    30.days.ago
  end
end
