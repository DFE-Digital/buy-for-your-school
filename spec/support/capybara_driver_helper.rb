require "capybara/cuprite"
require "json"
require "net/http"
require "socket"
require "uri"

JS_DRIVER = :cuprite

def remote_browser_config
  browser_url = ENV["CUPRITE_BROWSER_URL"].presence
  return {} unless browser_url

  { ws_url: (@remote_browser_ws_url ||= remote_browser_ws_url(browser_url)) }
end

def remote_browser_ws_url(browser_url)
  browser_uri = URI(browser_url)
  resolved_host = IPSocket.getaddress(browser_uri.host)
  version_uri = URI.join(browser_url.end_with?("/") ? browser_url : "#{browser_url}/", "json/version")
  version_uri.host = resolved_host
  response = JSON.parse(Net::HTTP.get(version_uri))
  ws_uri = URI(response.fetch("webSocketDebuggerUrl"))

  if ws_uri.host.nil? || %w[localhost 127.0.0.1].include?(ws_uri.host)
    ws_uri.scheme = "ws"
    ws_uri.host = resolved_host
    ws_uri.port ||= browser_uri.port
  end

  ws_uri.to_s
end

Capybara.register_driver :cuprite do |app|
  browser_options = {
    "no-sandbox" => nil,
    "disable-gpu" => nil,
    "disable-dev-shm-usage" => nil,
    "window-size" => "1920,1080",
  }

  Capybara::Cuprite::Driver.new(
    app,
    browser_path: ENV["CHROME_BINARY_PATH"].presence,
    browser_options:,
    headless: ENV["GUI"].blank?,
    process_timeout: 20,
    timeout: 10,
    window_size: [1920, 1080],
    **remote_browser_config,
  )
end

Capybara.configure do |config|
  config.default_driver = :rack_test
  config.javascript_driver = JS_DRIVER
  config.server = :puma, { Silent: true }

  Capybara.app_host = "http://www.example.com:3000"
  Capybara.asset_host = "http://www.example.com"

  config.server_host = ENV.fetch("CAPYBARA_SERVER_HOST") do
    if RUBY_PLATFORM.match?(/linux/)
      `/sbin/ip route|awk '/scope/ { print $9 }'`.chomp
    else
      "127.0.0.1"
    end
  end
end

RSpec.configure do |config|
  config.before do |example|
    if example.metadata[:js]
      # Some feature specs interact with form controls via labels or hidden inputs
      Capybara.ignore_hidden_elements = false
      Capybara.current_driver = JS_DRIVER

      server = Capybara.current_session.server
      Capybara.app_host = "http://#{server.host}:#{server.port}"
    end
  end

  config.after do
    Capybara.ignore_hidden_elements = true
    Capybara.use_default_driver
    Capybara.app_host = "http://www.example.com:3000"
  end
end
