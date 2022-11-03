# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BuyForYourSchool
  class Application < Rails::Application
    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: false,
                       request_specs: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Make sure the `form_with` helper generates local forms, instead of defaulting
    # to remote and unobtrusive XHR forms
    config.action_view.form_with_generates_remote_forms = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Automatically add UUID as the type of primary key on new tables, if you
    # use the Rails migration generator with 'create'
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.active_job.queue_adapter = :sidekiq

    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]
    config.i18n.default_locale = :en
    config.i18n.enforce_available_locales = false

    # Custom exception page handling
    config.exceptions_app = routes

    # Set London as the timezone - handles daylight savings automatically
    config.time_zone = "London"

    # Allows to enable new connection handling API
    config.active_record.legacy_connection_handling = false

    # detect bots in order to keep user journey data clean
    config.middleware.use Rack::CrawlerDetect
  end
end
