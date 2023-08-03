class MaintenanceMode
  ALLOWED_PATHS = ["/maintenance", "/flipper", "/assets"].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless Flipper.enabled?(:maintenance_mode)

    request = ActionDispatch::Request.new(env)
    if ALLOWED_PATHS.any? { |path| request.path.start_with?(path) }
      @app.call(env)
    else
      [301, { "Location" => "/maintenance", "Content-Type" => "text/html" }, []]
    end
  end
end
