class InsightsTracker
  def initialize(client:)
    @client = client
  end

  def track_event(name, properties: {}, measurements: {})
    @client.track_event("Events/#{name}", properties:, measurements:)
    @client.flush
  end

  def track_error(name, properties: {}, measurements: {})
    @client.track_event("Errors/#{name}", properties:, measurements:)
    @client.flush
  end
end
