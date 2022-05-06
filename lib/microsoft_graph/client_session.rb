module MicrosoftGraph
  # Graph API v1.0
  class ClientSession
    GraphRequestFailedError = Class.new(StandardError)

    attr_reader :authenticator

    def initialize(authenticator)
      @authenticator = authenticator
    end

    def graph_api_get(path)
      paginated_request(:get, api_path(path))
    end

    def graph_api_post(path, body, headers = {})
      enact_request(:post, api_path(path), body, headers)
    end

    def graph_api_patch(path, body, headers = {})
      enact_request(:patch, api_path(path), body, headers)
    end

  private

    def api_path(path)
      "https://graph.microsoft.com/v1.0/#{path}"
    end

    def enact_request(http_verb, request_url, body = {}, headers = {})
      puts http_verb
      puts request_url

      handle_api_response(
        HTTParty.send(
          http_verb,
          request_url,
          body: body,
          headers: { authorization: "Bearer #{access_token}" }.merge(headers),
        ),
      )
    end

    def paginated_request(http_verb, request_url, body = {}, headers = {})
      Enumerator.new do |yielder|
        loop do
          json = enact_request(http_verb, request_url, body, headers)

          json["value"].each { |value| yielder << value }

          break unless json.key?("@odata.nextLink")

          request_url = json["@odata.nextLink"]
          body = {}
        end
      end
    end

    def access_token
      authenticator.get_access_token
    end

    def handle_api_response(response)
      valid_response = response.code.to_s[0] == "2"

      if response.body == ""
        unless valid_response
          raise GraphRequestFailedError, "Status Code: #{response.code}"
        end
      else
        json = JSON.parse(response.body)

        if valid_response
          json
        else
          error_code = json.dig("error", "code")
          error_message = json.dig("error", "message")

          raise GraphRequestFailedError, "Code: #{error_code}, Message: #{error_message}"
        end
      end
    end
  end
end
