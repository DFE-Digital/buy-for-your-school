require "dry-initializer"
require "json"
require "yaml"

require "types"

# Convert data to format YAML/JSON and write to file
#
class Exporter
  extend Dry::Initializer

  option :path,   Types::Strict::String
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
