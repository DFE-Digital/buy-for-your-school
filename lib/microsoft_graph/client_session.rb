module MicrosoftGraph
  # Graph API v1.0
  class ClientSession
    AuthenticationFailureError = Class.new(StandardError)
    GraphRequestFailedError = Class.new(StandardError)

    def self.new_application_session(client_configuration)
      response = HTTParty.post(
        "https://login.microsoftonline.com/#{client_configuration.tenant}/oauth2/v2.0/token",
        body: {
          client_id: client_configuration.client_id,
          client_secret: client_configuration.client_secret,
          scope: client_configuration.scope,
          grant_type: client_configuration.grant_type,
        },
      )

      json = JSON.parse(response.body)

      if response.code == 200
        new(json["access_token"])
      else
        raise AuthenticationFailureError, json["error"]
      end
    end

    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token
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

  private

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
