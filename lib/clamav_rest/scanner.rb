module ClamavRest
  class Scanner
    attr_reader :configuration

    UnableToParseResponseError = Class.new(StandardError)

    def initialize(configuration)
      @configuration = configuration
    end

    def file_is_safe?(file)
      response = HTTParty.post(configuration.service_url, body: { file: }, format: :plain)
      status, _description = parse_response(response)

      status == "OK"
    rescue StandardError => e
      Rollbar.error(
        "ClamAV scan failed",
        error: e.class.name,
        message: e.message,
        backtrace: e.backtrace&.first(5),
        service_url: configuration.service_url,
      )
      false
    end

  private

    def parse_response(response)
      body = response.body

      raise UnableToParseResponseError if body == "" || !body.scan(/Status/)

      body.scan(/Status: "(.+)", Description: "(.?)"/).first
    end
  end
end
