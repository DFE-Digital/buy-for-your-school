if ENV["APPLICATION_URL"]
  first_url = ENV["APPLICATION_URL"].to_s.split(",").map(&:strip).first

  begin
    uri = URI.parse(first_url)

    Rails.application.routes.default_url_options[:host] = uri.host
    Rails.application.routes.default_url_options[:port] = uri.port unless [80, 443].include?(uri.port)
    Rails.application.routes.default_url_options[:protocol] = uri.scheme
  rescue URI::InvalidURIError => e
    Rails.logger.warn("[default_url_options] Invalid APPLICATION_URL: #{first_url} (#{e.message})")
  end
end
