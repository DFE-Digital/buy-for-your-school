module MicrosoftGraph
  class ClientConfiguration
    extend Dry::Initializer

    option :tenant, Types::Params::String
    option :client_id, Types::Params::String
    option :client_secret, Types::Params::String
    option :scope, Types::Params::String, default: -> { "https://graph.microsoft.com/.default" }
    option :grant_type, Types::Params::String, default: -> { "client_credentials" }
  end
end
