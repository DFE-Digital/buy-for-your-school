# Must mimic ApplicationInsights::TelemetryClient interface

class Tracking::RailsLoggerClient
  def track_event(name, properties:, measurements:)
    Rails.logger.info("Tracking") { "[#{name}] - #{properties} - #{measurements}" }
  end

  def flush
    # :noop:
  end
end
