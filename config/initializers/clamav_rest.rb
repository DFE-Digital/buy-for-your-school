require "clamav_rest/clamav_rest"

clamav_configuration = ClamavRest::Configuration.new(
  service_url: ENV["CLAMAV_REST_SERVICE_URL"],
)

ClamavRest.get_scanner_strategy = lambda {
  if Flipper.enabled?(:clamav_rest)
    ClamavRest::Scanner.new(clamav_configuration)
  else
    ClamavRest::MockScanner.new(is_safe: true)
  end
}
