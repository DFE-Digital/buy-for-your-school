JS_DRIVER = (ENV["GUI"] ? :chrome : :headless_chrome)

Capybara.register_driver :headless_chrome do |app|
  chrome_options = Selenium::WebDriver::Chrome::Options.new
  chrome_options.add_argument("no-sandbox")
  chrome_options.add_argument("headless")
  chrome_options.add_argument("disable-gpu")
  chrome_options.add_argument("window-size=1400,1400")

  if ENV["SELENIUM_HUB_URL"]
    # use remote chrome (docker default)
    Capybara::Selenium::Driver.new(app, browser: :remote, url: ENV["SELENIUM_HUB_URL"], capabilities: [chrome_options])
  else
    # use chromedriver (local setup - ensure your chrome, chromedriver and selenium-webdriver gem versions all match)
    Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: [chrome_options])
  end
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
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
      # chromedriver is unforgiving of hidden form elements triggered by labels
      # e.g. radio buttons
      Capybara.ignore_hidden_elements = false
      Capybara.current_driver = JS_DRIVER

      # if ENV["SELENIUM_HUB_URL"]
      server = Capybara.current_session.server
      Capybara.app_host = "http://#{server.host}:#{server.port}"
      # end
    end
  end

  config.after do
    # reset to defaults
    Capybara.ignore_hidden_elements = true
    Capybara.use_default_driver
    Capybara.app_host = "http://www.example.com:3000"
  end
end
