uri = URI(ENV["APPLICATION_URL"])

Rails.application.routes.default_url_options[:host] = uri.host
Rails.application.routes.default_url_options[:port] = uri.port
Rails.application.routes.default_url_options[:protocol] = uri.scheme
