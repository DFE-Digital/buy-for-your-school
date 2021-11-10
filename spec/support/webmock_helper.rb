require "webmock/rspec"

allow_list = if ENV["SELENIUM_HUB_URL"]
               hub_uri = URI(ENV["SELENIUM_HUB_URL"])

               # capybara must be able to make requests to the selenium hub
               # and from the browser it must be able to make requests back to the server

               [
                 "#{hub_uri.scheme}://#{hub_uri.host}:#{hub_uri.port}",
                 IPSocket.getaddress(Socket.gethostname),
               ]
             else
               []
             end

WebMock.disable_net_connect!(allow_localhost: true, allow: allow_list)
