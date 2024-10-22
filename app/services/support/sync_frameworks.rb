module Support
  class SyncFrameworks
    include InsightsTrackable

    def initialize(endpoint: ENV["FAF_FRAMEWORK_ENDPOINT"])
      @endpoint = endpoint
    end

    def call
      fetch_frameworks
      upsert_frameworks if @frameworks.present?
    end

  private

    def fetch_frameworks
      uri = URI.parse(@endpoint)
      response =
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
          request = Net::HTTP::Get.new(uri)
          http.request(request)
        end

      if response.code == "200"
        @frameworks = JSON.parse(response.body)
      else
        track_error("SyncFrameworks/CouldNotFetchFrameworks", uri: @endpoint, status: response.code)
      end
    end

    def upsert_frameworks
      prepared_frameworks = prepare_frameworks(@frameworks)
      Support::Framework.upsert_all(
        prepared_frameworks,
        unique_by: %i[ref, index_support_frameworks_on_name_and_supplier],
      )
    end

    def prepare_frameworks(frameworks)
      frameworks.select { |framework| framework["expiry"].present? }.map do |framework|
        {
          name: framework["title"],
          ref: framework["ref"],
          supplier: framework["provider"].try(:[], "initials"),
          category: framework["cat"].try(:[], "title"),
          expires_at: Date.parse(framework["expiry"]),
        }
      end
    end
  end
end
