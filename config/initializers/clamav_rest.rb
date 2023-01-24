require "clamav_rest/clamav_rest"

Rails.configuration.to_prepare do
  if Rails.env.production? || ENV["CLAM_AV_REST_ENABLED"] == "1"
    clamav_configuration = ClamavRest::Configuration.new(
      service_url: ENV["CLAMAV_REST_SERVICE_URL"],
    )

    ClamavRest.scanner = ClamavRest::Scanner.new(clamav_configuration)
  else
    # Always return file is safe
    ClamavRest.scanner = ClamavRest::MockScanner.new(is_safe: true)
  end

  Rails.configuration.clamav_scanner = ClamavRest.scanner
end
