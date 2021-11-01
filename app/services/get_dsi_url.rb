require "dry-initializer"

require "types"

# Generate Dfe Sign In URLs for the active environment:
# production (default), pre-production, test
#
# TODO: rename and move to ::Dsi::Url
class GetDsiUrl
  extend Dry::Initializer

  # @!attribute [r] env
  #   @return [Symbol] default :production
  option :env, Types::Params::Symbol, default: proc { ENV.fetch("DSI_ENV", "production") }

  # @!attribute subdomain
  #   @return [String]
  #   @api private
  option :subdomain, default: proc { "services" }, reader: :private

  # @!attribute path
  #   @return [String]
  #   @api private
  option :path, optional: true, reader: :private

  # TODO: consider wrapping in URL(xxx), will stringify when rendered
  #
  # @return [String] HTTPS url
  def call
    "https://#{prefix}#{subdomain}.signin.education.gov.uk/#{path}"
  end

private

  # @return [String] ENV prefix
  def prefix
    { production: nil, staging: "pp-", test: "test-" }.fetch(env)
  end
end
