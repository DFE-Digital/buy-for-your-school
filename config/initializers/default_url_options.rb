application_url = ENV['APPLICATION_URL'] || ENV['CONTAINER_APP_HOSTNAME']

if application_url
  uri = URI(application_url)

  Rails.application.routes.default_url_options[:host] = uri.host
  Rails.application.routes.default_url_options[:port] = uri.port
  Rails.application.routes.default_url_options[:protocol] = uri.scheme || (ENV['CONTAINER_APP_HOSTNAME'].present? ? 'https' : nil)
end
