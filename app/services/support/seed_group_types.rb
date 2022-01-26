require "yaml"
require "dry-initializer"
require "types"

module Support
  #
  # Persist "grouped establishment types" that the service supports from YAML file
  #
  # @example
  #   SeedGroupTypes.new(data: "/path/to/file.yml").call
  #
  class SeedGroupTypes
    extend Dry::Initializer

    # @!attribute [r] data
    # @return [String] (defaults to ./config/support/establishment_types.yml)
    option :data, Types::String, default: proc { "./config/support/establishment_types.yml" }

    # @return [Array<Hash>]
    #
    def call
      YAML.load_file(data).each do |group_type|
        group = GroupType.find_or_create_by!(**group_type.slice(:name, :code))

        group_type[:establishments].each do |type|
          EstablishmentType.find_or_create_by!(group_type_id: group.id, **type.slice(:name, :code))
        end
      end
    end
  end
end
