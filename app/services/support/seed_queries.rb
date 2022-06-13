require "yaml"
require "dry-initializer"
require "types"

module Support
  #
  # Persist queries from YAML file
  #
  # @example
  #   SeedQueries.new(data: "/path/to/file.yml").call
  #
  class SeedQueries
    extend Dry::Initializer

    # @!attribute [r] data
    # @return [String] (defaults to ./config/support/queries.yml)
    option :data, Types::String, default: proc { "./config/support/queries.yml" }
    # @!attribute [r] reset
    # @return [Boolean] (defaults to false)
    option :reset, Types::Bool, default: proc { false }

    # @return [Array<Hash>]
    #
    def call
      Query.destroy_all if reset

      YAML.load_file(data).each do |entry|
        Query.find_or_create_by!(title: entry) do |q|
          q.title = entry
        end
      end
    end
  end
end

# check this file
