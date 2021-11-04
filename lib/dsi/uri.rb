require "dry-initializer"

require "types"

# Generate Dfe Sign In URLs for the active environment:
# production (default), pre-production, test
#
module Dsi
  class Uri
    extend Dry::Initializer

    # @!attribute env
    #   @return [Symbol] default :production
    #   @api private
    option :env,
           default: proc { ENV.fetch("DSI_ENV", "production") },
           type: Types::Params::Symbol.enum(*%i[production staging test]),
           reader: :private

    # @!attribute subdomain
    #   @return [String]
    #   @api private
    option :subdomain, default: proc { "services" }, reader: :private

    # @!attribute path
    #   @return [String]
    #   @api private
    option :path, optional: true, reader: :private

    # @!attribute query
    #   @return [String]
    #   @api private
    option :query,
           proc(&:to_query),
           optional: true,
           reader: :private

    # @return [URI::HTTPS]
    def call
      URI::HTTPS.build(
        host: "#{prefix}#{subdomain}.signin.education.gov.uk",
        path: path,
        query: query,
      )
    end

  private

    # @return [String] ENV prefix
    def prefix
      { production: nil, staging: "pp-", test: "test-" }.fetch(env)
    end
  end
end
