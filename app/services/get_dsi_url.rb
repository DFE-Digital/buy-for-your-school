require "dry-initializer"

# Generate Dfe Sign In URLs for the active environment:
# test, pre-production, production
class GetDsiUrl
  extend Dry::Initializer

  # @!attribute domain
  #   @return [String]
  #   @api private
  option :domain, default: proc { "services" }, reader: :private

  # @!attribute path
  #   @return [String]
  #   @api private
  option :path, optional: true, reader: :private

  # @return [String] HTTPS url
  def call
    "https://#{env_prefix}#{domain}.signin.education.gov.uk/#{path}"
  end

private

  # @return [String] ENV prefix
  def env_prefix
    @env_prefix = {
      production: nil,
      staging: "pp-",
      test: "test-",
      development: "test-",
    }.fetch(Rails.env.to_sym)
  end
end
