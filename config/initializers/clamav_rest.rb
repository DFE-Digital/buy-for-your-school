require "clamav_rest/clamav_rest"

Rails.configuration.to_prepare do
  if Rails.env.production? || ENV["CLAM_AV_REST_ENABLED"] == "1"
    service_url = ENV.fetch(
      "CLAMAV_REST_SERVICE_URL",
      "http://#{ENV['CLAM_AV_SERVICE_NAME']}.internal.#{ENV['CONTAINER_APP_ENV_DNS_SUFFIX']}"
    )

    ClamavRest.scanner = ClamavRest::Scanner.new(ClamavRest::Configuration.new(service_url:))
  else
    # Always return file is safe
    ClamavRest.scanner = ClamavRest::MockScanner.new(is_safe: true)
  end

  Rails.configuration.clamav_scanner = ClamavRest.scanner
end
