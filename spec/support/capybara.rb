# frozen_string_literal: true

#Capybara.app_host = "http://www.example.com:3000"
#Capybara.asset_host = "http://www.example.com"
#

Capybara.register_server :puma do |app, port, host|
  require "rack/handler/puma"
  Rack::Handler::Puma.run(app, Host: host, Port: port, Threads: "0:4", config_files: ["-"], Silent: true)
end

Capybara.configure do |config|
  #config.match = :prefer_exact
  #config.ignore_hidden_elements = true
  #config.automatic_reload = false
  port = 7787
  Capybara.server_port = port
  config.app_host = "http://127.0.0.1:#{port}"
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

# rack_test / chrome
Capybara.default_driver = :chrome

