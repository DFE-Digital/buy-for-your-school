module MicrosoftGraph
  # Graph API v1.0
  class ClientSession
    GraphRequestFailedError = Class.new(StandardError)

    attr_reader :authenticator

    def initialize(authenticator)
      @authenticator = authenticator
    end

    def graph_api_get(path)
      paginated_request(:get, path)
    end

    def graph_api_post(path, body)
      paginated_request(:post, path, body)
    end

    def graph_api_patch(path, body)
      paginated_request(:patch, path, body)
    end

  private

    def paginated_request(http_verb, initial_path, body = {})
      request_url = "https://graph.microsoft.com/v1.0/#{initial_path}"
      overral_response = { "value" => [] }

      loop do
        json = handle_api_response(
          HTTParty.send(
            http_verb,
            request_url,
            body: body,
            headers: { authorization: "Bearer #{access_token}" },
          ),
        )

        overral_response["value"].concat(json["value"])

        if json.key?("@odata.nextLink")
          request_url = json["@odata.nextLink"]
          body = {}
        else
          break
        end
      end

      overral_response
    end

    def access_token
      authenticator.get_access_token
    end

    def handle_api_response(response)
      json = JSON.parse(response.body)
      valid_response = response.code.to_s[0] == "2"

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
