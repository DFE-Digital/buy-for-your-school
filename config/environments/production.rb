require "active_support/core_ext/integer/time"
# Load environment variables that are created by GPaaS
require_relative "../../lib/vcap_parser"
VcapParser.load_service_environment_variables!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :terser
  config.assets.css_compressor = nil

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Log to STDOUT and include the current request id from App Insights
  config.log_tags = [
    :request_id,
    ->(request) { request.env["ApplicationInsights.request.id"] },
  ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Don't log SQL queries
  config.active_record.logger = nil 

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Log to STDOUT if environment variable defined (Used on Azure Dev)
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Replace the default in-process memory cache store with a durable alternative.
  # config.cache_store = :mem_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  # config.active_job.queue_adapter = :resque

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "example.com" }

  # Specify outgoing SMTP server. Remember to add smtp/* credentials via bin/rails credentials:edit.
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # NB: ITHC finding 6.1.3 mitigation
  config.action_dispatch.default_headers = {
    "X-Xss-Protection" => "0",
    "X-Frame-Options" => "DENY",
    "X-Content-Type-Options" => "nosniff",
  }

  # Set active storage location
  config.active_storage.service = if ENV["AZURE_STORAGE_ACCOUNT_NAME"].present?
                                    :azure
                                  elsif ENV["BUCKET_NAME"].present?
                                    :amazon
                                  else
                                    :local
                                  end

  # Application insights
  application_insights_key = ENV["ApplicationInsights__InstrumentationKey"]
  if application_insights_key.present?
    require "middleware/application_insights_track_request_conditionally"
    config.middleware.use ApplicationInsightsTrackRequestConditionally, instrumentation_key: application_insights_key, ignore_paths: ["/cable"]
    # send unhandled exceptions
    ApplicationInsights::UnhandledException.collect(application_insights_key)
  end

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  [
    ENV["APPLICATION_URL"],
    ENV["CONTAINER_APP_HOSTNAME"],
  ].each do |hostname|
    config.hosts << hostname.split("://").last if hostname.present?
  end
  config.hosts.concat(ENV["ALLOWED_HOSTS"].split(","))      if ENV["ALLOWED_HOSTS"].present?
  config.hosts << IPAddr.new(ENV["CONTAINER_VNET_CIDR"])    if ENV["CONTAINER_VNET_CIDR"].present?
  config.hosts << ".#{ENV['CONTAINER_APP_ENV_DNS_SUFFIX']}" if ENV["CONTAINER_APP_ENV_DNS_SUFFIX"].present?

  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
