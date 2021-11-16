require "dry-initializer"
require "json"
require "yaml"

require "types"

# Convert data to format YAML/JSON and write to file
#
class Exporter
  extend Dry::Initializer

  # @!attribute [r] path
  # @return [String]
  option :path,   Types::Strict::String
  # @!attribute [r] format
  # @return [Symbol] yaml or json
  option :format, Types::Strict::Symbol.enum(:yaml, :json)

  def call(data)
    File.open(path, "w") do |file|
      case format
      when :yaml
        file.write(data.to_yaml)
      when :json
        file.write(data.to_json)
      end
    end
  end
end
