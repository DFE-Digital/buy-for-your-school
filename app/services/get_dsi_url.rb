require "dry-initializer"

# Get DSI URL for current environment
#
# @return [String]
class GetDsiUrl
  extend Dry::Initializer

  option :domain, default: proc { "services" }, reader: :private
  option :path, optional: true, reader: :private

  def call
    "https://#{env_prefix}#{domain}.signin.education.gov.uk/#{path}"
  end

private

  def env_prefix
    @env_prefix = {
      production: nil,
      staging: "pp-",
      test: "test-",
      development: "test-",
    }.fetch(Rails.env.to_sym)
  end
end
