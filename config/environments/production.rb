# frozen_string_literal: true

require "active_support/core_ext/integer/time"
# Load environment variables that are created by GPaaS
require_relative "../../lib/vcap_parser"
VcapParser.load_service_environment_variables!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :terser
  # Set a css_compressor so sassc-rails does not overwrite the compressor when running the tests
  config.assets.css_compressor = nil

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [
    :request_id,
    ->(request) { request.env["ApplicationInsights.request.id"] }, # app insights request id
  ]

  config.active_record.logger = nil # Don't log SQL

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "buy_for_your_school_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Inserts middleware to perform automatic connection switching.
  # The `database_selector` hash is used to pass options to the DatabaseSelector
  # middleware. The `delay` is used to determine how long to wait after a write
  # to send a subsequent read to the primary.
  #
  # The `database_resolver` class is used by the middleware to determine which
  # database is appropriate to use based on the time delay.
  #
  # The `database_resolver_context` class is used by the middleware to set
  # timestamps for the last write to the primary. The resolver uses the context
  # class timestamps to determine how long to wait before reading from the
  # replica.
  #
  # By default Rails will store a last write timestamp in the session. The
  # DatabaseSelector middleware is designed as such you can define your own
  # strategy for connection switching and pass that into the middleware through
  # these configuration options.
  # config.active_record.database_selector = { delay: 2.seconds }
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session

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

  # hosts setup
  config.middleware.use DomainRedirector

  application_urls = ENV["APPLICATION_URL"].to_s.split(",").map(&:strip)

  application_urls.each do |url|
    config.hosts << url.split("://").last if url.present?
  end

  [
    ENV["CONTAINER_APP_HOSTNAME"],
  ].each do |hostname|
    config.hosts << hostname.split("://").last if hostname.present?
  end
  config.hosts.concat(ENV["ALLOWED_HOSTS"].split(","))      if ENV["ALLOWED_HOSTS"].present?
  config.hosts << IPAddr.new(ENV["CONTAINER_VNET_CIDR"])    if ENV["CONTAINER_VNET_CIDR"].present?
  config.hosts << ".#{ENV['CONTAINER_APP_ENV_DNS_SUFFIX']}" if ENV["CONTAINER_APP_ENV_DNS_SUFFIX"].present?
end
