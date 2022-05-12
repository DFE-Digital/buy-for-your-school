module ClamavRest
  class Configuration
    attr_reader :service_url, :logger

    def initialize(service_url:)
      @service_url = service_url
    end
  end
end
