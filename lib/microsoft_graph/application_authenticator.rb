module MicrosoftGraph
  class ApplicationAuthenticator
    AuthenticationFailureError = Class.new(StandardError)

    attr_reader :client_configuration

    def initialize(client_configuration)
      @client_configuration = client_configuration
      @access_token = nil
      @access_token_expiry = Time.now
    end

    def get_access_token
      return access_token if access_token_valid?

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
        @access_token = json["access_token"]
        @access_token_expiry = Time.now + json["expires_in"]

        @access_token
      else
        raise AuthenticationFailureError, [json["error"], json["error_description"]].compact.join(": ")
      end
    end

    def access_token_valid?
      access_token.present? && access_token_expiry > (Time.now + 10)
    end

  private

    attr_reader :access_token, :access_token_expiry
  end
end
