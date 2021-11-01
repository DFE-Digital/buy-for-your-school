require "dry-initializer"

require "types"

# Generate Dfe Sign In URLs for the active environment:
# production (default), pre-production, test
#
module Dsi
  class Uri
    extend Dry::Initializer

    # @!attribute [r] env
    #   @return [Symbol] default :production
    #   @api private
    option :env, Types::Params::Symbol, default: proc { ENV.fetch("DSI_ENV", "production") }, reader: :private

    # @!attribute subdomain
    #   @return [String]
    #   @api private
    option :subdomain, default: proc { "services" }, reader: :private

    # @!attribute path
    #   @return [String]
    #   @api private
    option :path, optional: true, reader: :private

    # @return [URI::HTTPS]
    def call
      URI("https://#{prefix}#{subdomain}.signin.education.gov.uk/#{path}")
    end

  private

    # @return [String] ENV prefix
    def prefix
      { production: nil, staging: "pp-", test: "test-" }.fetch(env)
    end
  end
end
