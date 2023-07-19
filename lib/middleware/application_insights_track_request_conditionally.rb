require "application_insights"

class ApplicationInsightsTrackRequestConditionally
  def initialize(app, instrumentation_key:, ignore_paths: [])
    @app = app
    @instrumentation_key = instrumentation_key
    @ignore_paths = ignore_paths
    @application_insights = ApplicationInsights::Rack::TrackRequest.new(app, instrumentation_key)
  end

  def call(env)
    request = ::Rack::Request.new env
    if request.path.in?(@ignore_paths)
      @app.call(env)
    else
      @application_insights.call(env)
    end
  end
end
