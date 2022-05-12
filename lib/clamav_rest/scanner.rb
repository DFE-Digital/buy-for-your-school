module ClamavRest
  class Scanner
    attr_reader :configuration

    UnableToParseResponseError = Class.new(StandardError)

    def initialize(configuration)
      @configuration = configuration
    end

    def file_is_safe?(file)
      response = HTTParty.post(configuration.service_url, body: {file: file}, format: :plain)
      status, description = parse_response(response)

      status == "OK"
    rescue StandardError => error
      false
    end

    private

    def parse_response(response)
      body = response.body

      raise UnableToParseResponseError if body == "" || !(body.scan(/Status/))

      body.scan(/Status: \"(.+)\", Description: \"(.?)\"/).first
    end
  end
end
