JS_DRIVER = :chrome_headless

Capybara.register_driver :chrome_headless do |app|
  chrome_capabilities = ::Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions" => {
      args: %w[no-sandbox headless disable-gpu window-size=1400,1400],
    },
  )

  if ENV["SELENIUM_HUB_URL"]
    # use remote chrome (docker default)
    Capybara::Selenium::Driver.new(app, browser: :remote, url: ENV["SELENIUM_HUB_URL"], desired_capabilities: chrome_capabilities)
  else
    # use chromedriver (local setup - ensure your chrome, chromedriver and selenium-webdriver gem versions all match)
    Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: chrome_capabilities)
  end
end

Capybara.configure do |config|
  config.default_driver = :rack_test
  config.javascript_driver = JS_DRIVER
  config.server = :puma, { Silent: true }
  config.always_include_port = true

  config.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}:3000"
  config.server_host = IPSocket.getaddress(Socket.gethostname)
  config.server_port = 3000
end

RSpec.configure do |config|
  config.before do |example|
    if example.metadata[:js]
      # chromedriver is unforgiving of hidden form elements triggered by labels
      # e.g. radio buttons
      Capybara.ignore_hidden_elements = false
      Capybara.current_driver = JS_DRIVER
    end
  end

  config.after do
    # reset to defaults
    Capybara.ignore_hidden_elements = true
    Capybara.use_default_driver
  end
end
