DfE::Analytics.configure do |config|
  # Whether to log events instead of sending them to BigQuery.
  #
  # config.log_only = true

  # Whether to use ActiveJob or dispatch events immediately.
  #
  # config.async = true

  # Which ActiveJob queue to put events on
  #
  # config.queue = :dfe_analytics

  # The name of the BigQuery table we’re writing to.
  #
  config.bigquery_table_name = ENV["BIGQUERY_TABLE_NAME"]

  # The name of the BigQuery project we’re writing to.
  #
  config.bigquery_project_id = ENV["BIGQUERY_PROJECT_ID"]

  # The name of the BigQuery dataset we're writing to.
  #
  config.bigquery_dataset = ENV["BIGQUERY_DATASET"]

  # Service account JSON key for the BigQuery API. See
  # https://cloud.google.com/bigquery/docs/authentication/service-account-file
  #
  config.bigquery_api_json_key = ENV["BIGQUERY_API_JSON_KEY"]

  # Passed directly to the retries: option on the BigQuery client
  #
  # config.bigquery_retries = 3

  # Passed directly to the timeout: option on the BigQuery client
  #
  # config.bigquery_timeout = 120

  # A proc which returns true or false depending on whether you want to
  # enable analytics. You might want to hook this up to a feature flag or
  # environment variable.
  #
  config.enable_analytics = proc { ENV.fetch("ENABLE_DFE_ANALYTICS", nil) == "TRUE" }

  # The environment we’re running in. This value will be attached
  # to all events we send to BigQuery.
  #
  config.environment = ENV.fetch("RAILS_ENV", "development")

  # A proc which will be called with the user object, and which should
  # return the identifier for the user. This is useful for systems with
  # users that don't use the id field.
  #
  # config.user_identifier = proc { |user| user&.id }

  # Whether to run entity table checksum job.
  #
  # config.entity_table_checks_enabled = false

  # A proc which will be called with the rack env, and which should
  # return a boolean indicating whether the page is cached and will
  # be served by rack middleware.
  #
  # config.rack_page_cached = proc { |_rack_env| false }

  # Schedule a maintenance window during which no events are streamed to BigQuery
  # in the format of '22-01-2024 19:30..22-01-2024 20:30' (UTC).
  #
  # config.bigquery_maintenance_window = ENV['BIGQUERY_MAINTENANCE_WINDOW']

  # Whether to use azure workload identity federation for authentication
  # instead of the BigQuery API JSON Key. Note that this also will also
  # use a new version of the BigQuery streaming APIs.
  #
  config.azure_federated_auth = false

  # Client Id of the app in azure
  #
  # config.azure_client_id = ENV['AZURE_CLIENT_ID']

  # Path of token file for used for getting token from azure ad
  #
  # config.azure_token_path = ENV['AZURE_FEDERATED_TOKEN_FILE']

  # Azure audience scope
  #
  # config.azure_scope = api://AzureADTokenExchange/.default

  # Google cloud scope
  #
  # config.gcp_scope = https://www.googleapis.com/auth/cloud-platform

  # Google generated cloud credentials file
  #
  # config.google_cloud_credentials = ENV['GOOGLE_CLOUD_CREDENTIALS']

  # Translation missing: en.dfe.analytics.config.excluded_paths.description
  #
  config.excluded_paths = [
    "/health",
    "/status",
    %r{\.sql(\.(zip|tar\.gz|bz2|xz|rar|7z|z))?$},
    %r{\.php(\.|$)},
    %r{\.php7(\.|$)},
    %r{\.json(\.|$)},
    %r{\.js(\.|$)},
    %r{\.yaml(\.|$)},
    %r{\.yml(\.|$)},
    %r{\.axd(\.|$)},
    %r{\.cfc(\.|$)},
    %r{\.jsf(\.|$)},
    %r{\.jspa(\.|$)},
    %r{\.aspx(\.|$)},
    %r{\.ashx(\.|$)},
    %r{\.xml(\.|$)},
    %r{\.docx(\.|$)},
    %r{\.html(\.|$)},
    %r{\.htm(\.|$)},
    %r{\.css(\.|$)},
    %r{\.txt(\.|$)},
    %r{\.BshServlet(\.|$)},
    %r{\.action(\.|$)},
    %r{\.osx(\.|$)},
    %r{\.ico(\.|$)},
    %r{\.icw(\.|$)},
    %r{\.cgi(\.|$)},
    %r{\.xsi(\.|$)},
    %r{\.conf(\.|$)},
    %r{\.env(\.|$)},
    %r{\.map(\.|$)},
    %r{\.do(\.|$)},
    %r{\.sql(\.|$)},
    %r{\.exe(\.|$)},
    %r{\.ini(\.|$)},
    %r{\.db(\.|$)},
    %r{^/admin/},
    %r{^/conf/},
    %r{^/wp-},
    %r{^/tmp/},
    %r{^/backups?/},
    %r{^/inc/},
    %r{^/ajax/},
    %r{^/uploadify/},
    %r{^/package\.},
    %r{^/data\.},
    %r{oast\.me},
    %r{^/\.git/},
    %r{^/api/},
    %r{^/virtualems/},
    %r{^/admin/},
    %r{^/calendarix/},
    %r{^/dotnetnuke/},
    %r{^/desktopmodules/},
    %r{^/DesktopModules/},
    %r{^/administrator/},
    %r{^/\.well-known/},
    %r{^/wp-content/},
    %r{^/assets/},
    %r{^/images/},
    %r{^/img/},
    %r{^/imgs/},
    %r{^/static/},
    %r{^/statics/},
    %r{^/themes/},
    %r{^/cgi-bin/},
    %r{^/swagger/},
    %r{^/scripts/},
    %r{^/html/},
    %r{^/ssl/},
    %r{^/weaver/},
    %r{^/certificates/},
    %r{^/\..+},
  ]

  # A proc which will be called during model initialization. It allows to disable models
  # which should not be used. Each model is passed to bloc and if bloc returns true for the model,
  # it wont be used by the application. Eg: proc { |x| x.to_s =~ /Namespace::/ } will exclude all
  # models namespaced with Namespace
  #
  # config.excluded_models_proc = proc { |_model| false }
end
