module InsightsTrackable
  extend ActiveSupport::Concern

protected

  def track_event(event_name, custom_properties = {})
    properties = custom_properties.merge(tracking_base_properties)
    tracker.track_event(event_name, properties:)
  end

  def track_error(error_name, custom_properties = {})
    error_properties = custom_properties[:error].present? ? { errorMessage: error.message, errorType: error.class } : {}
    properties = custom_properties.merge(tracking_base_properties).merge(error_properties)
    tracker.track_error(error_name, properties:)
  end

  def tracking_base_properties = {}

private

  def tracker
    InsightsTracker.new(client: tracker_client)
  end

  def tracker_client
    if ENV["ApplicationInsights__InstrumentationKey"].present?
      ApplicationInsights::TelemetryClient.new(ENV["ApplicationInsights__InstrumentationKey"])
    else
      Tracking::RailsLoggerClient.new
    end
  end
end
