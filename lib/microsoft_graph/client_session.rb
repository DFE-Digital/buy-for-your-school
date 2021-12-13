module MicrosoftGraph
  # Graph API v1.0
  class ClientSession
    GraphRequestFailedError = Class.new(StandardError)

    attr_reader :authenticator

    def initialize(authenticator)
      @authenticator = authenticator
    end

    def graph_api_get(path)
      response = HTTParty.get(
        "https://graph.microsoft.com/v1.0/#{path}",
        headers: { authorization: "Bearer #{access_token}" },
      )

      handle_api_response(response)
    end

    def graph_api_post(path, body)
      response = HTTParty.post(
        "https://graph.microsoft.com/v1.0/#{path}",
        headers: { authorization: "Bearer #{access_token}" },
        body: body,
      )

      handle_api_response(response)
    end

    def graph_api_patch(path, body)
      response = HTTParty.patch(
        "https://graph.microsoft.com/v1.0/#{path}",
        headers: { authorization: "Bearer #{access_token}", "Content-Type": "application/json" },
        body: body,
      )

      handle_api_response(response)
    end

  private

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
