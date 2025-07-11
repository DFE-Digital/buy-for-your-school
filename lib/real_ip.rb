class RealIp
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    env["HTTP_X_REAL_IP"] = request.remote_ip

    @app.call(env)
  end
end
