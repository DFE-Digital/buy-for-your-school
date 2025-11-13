# lib/middleware/domain_redirector.rb
class DomainRedirector
  def initialize(app)
    @app = app
    @primary_host = URI.parse(ENV["APPLICATION_URL"].to_s.split(",").map(&:strip).first).host
    @allowed_hosts = ENV["APPLICATION_URL"].to_s.split(",").map { |url| URI.parse(url.strip).host }
  end

  def call(env)
    req = Rack::Request.new(env)

    if @allowed_hosts.include?(req.host) && req.host != @primary_host
      redirect_url = URI::HTTPS.build(host: @primary_host, path: "/", query: URI.encode_www_form(source: req.url))
      return [301, { "Location" => redirect_url, "Content-Type" => "text/html" }, ["Moved Permanently"]]
    end

    @app.call(env)
  end
end
