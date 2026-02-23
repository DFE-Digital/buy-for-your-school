VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Capybara pings the local server with /__identify__ to make sure it booted.
  # These requests aren't part of any external API interaction so we let them
  # bypass VCR/WebMock entirely.
  selenium_hub_host = begin
    hub_url = ENV["SELENIUM_HUB_URL"]
    URI(hub_url).host if hub_url && !hub_url.empty?
  rescue URI::InvalidURIError
    nil
  end

  ignored_hosts = [
    "127.0.0.1",
    "localhost",
    (Capybara.server_host if defined?(Capybara)),
    selenium_hub_host,
  ].compact.uniq
  config.ignore_hosts(*ignored_hosts) if ignored_hosts.any?

  config.filter_sensitive_data("FAKE_API_KEY") { ENV["CONTENTFUL_ACCESS_TOKEN"] }
  config.filter_sensitive_data("FAKE_SPACE_ID") { ENV["CONTENTFUL_SPACE_ID"] }
  config.filter_sensitive_data("FAKE_OPENSEARCH_URL") { ENV["OPENSEARCH_URL"] }
  config.default_cassette_options = {
    record: (ENV["RECORD_VCR"] == "1" ? :all : :once),
    match_requests_on: %i[method uri body],
    allow_playback_repeats: true,
  }
end

WebMock.disable_net_connect!
