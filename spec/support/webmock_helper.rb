require "webmock/rspec"

allow_list = if ENV["CUPRITE_BROWSER_URL"]
               browser_uri = URI(ENV["CUPRITE_BROWSER_URL"])
               browser_ip = IPSocket.getaddress(browser_uri.host)

               # capybara must be able to make requests to the remote browser
               # and from the browser it must be able to make requests back to the server

               [
                 "#{browser_uri.scheme}://#{browser_uri.host}:#{browser_uri.port}",
                 "#{browser_uri.scheme}://#{browser_ip}:#{browser_uri.port}",
                 IPSocket.getaddress(Socket.gethostname),
               ]
             else
               []
             end

WebMock.disable_net_connect!(allow_localhost: true, allow: allow_list)
