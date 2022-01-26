require "yaml"
require "dry-initializer"
require "types"

module Support
  #
  # Persist "grouped establishment types" that the service supports from YAML file
  #
  # @example
  #   SeedEstablishmentGroupTypes.new(data: "/path/to/file.yml").call
  #
  class SeedEstablishmentGroupTypes
    extend Dry::Initializer

    # @!attribute [r] data
    # @return [String] (defaults to ./config/support/establishment_group_types.yml)
    option :data, Types::String, default: proc { "./config/support/establishment_group_types.yml" }

    # @return [Array<Hash>]
    #
    def call
      YAML.load_file(data).each do |group|
        EstablishmentGroupType.find_or_create_by!(**group.slice(:name, :code))
      end
    end
  end
end
