require "dry-initializer"

require "types"

# Generate Dfe Sign In URLs for the active environment:
# production (default), pre-production, test
#
module Dsi
  class Uri
    extend Dry::Initializer

    # @!attribute env
    #   @return [Symbol] production (default), staging or test
    #   @api private
    option :env,
           default: proc { ENV.fetch("DSI_ENV", "production") },
           type: Types::Params::Symbol.enum(*%i[production staging test]),
           reader: :private

    # @!attribute subdomain
    #   @return [String]
    #   @api private
    option :subdomain,
           default: proc { "services" },
           type: Types::String,
           reader: :private

    # @!attribute path
    #   @return [String]
    #   @api private
    option :path,
           optional: true,
           type: Types::String.optional.constrained(format: /^\//),
           reader: :private

    # @!attribute query
    #   @return [String]
    #   @api private
    option :query,
           optional: true,
           type: Types::String.optional,
           reader: :private

    # @return [URI::HTTPS]
    def call
      URI::HTTPS.build(
        host: "#{prefix}#{subdomain}.signin.education.gov.uk",
        path:,
        query:,
      )
    end

  private

    # @return [String] ENV prefix
    def prefix
      { production: nil, staging: "pp-", test: "test-" }.fetch(env)
    end
  end
end
