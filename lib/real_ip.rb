class RealIp
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    if request.remote_ip
      env["HTTP_X_REAL_IP"] = request.remote_ip
    end

    @app.call(env)
  end
end
