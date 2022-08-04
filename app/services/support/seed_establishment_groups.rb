require "yaml"
require "dry-initializer"
require "support/establishment_groups/information"
require "support/establishment_groups/record_keeper"

module Support
  #
  # Persist "establishment group types" that the service supports from YAML file
  #
  # @example
  #   SeedEstablishmentGroups.new(data: "/path/to/file.yml").call
  #
  class SeedEstablishmentGroups
    extend Dry::Initializer
    # Optional path to local file or will download and use latest data from GIAS
    #
    # @!attribute [r] data
    # @!visibility private
    option :data, reader: :private, optional: true

    # Persistence logic
    # (defaults to School::RecordKeeper)
    #
    # @!attribute [r] saver
    # @!visibility private
    option :saver, reader: :private, default: proc { ::Support::EstablishmentGroups::RecordKeeper.new }

    # Filter records that do match these criteria
    #
    # @!attribute [r] filter
    # @!visibility private
    # @return [Hash] "column header" => [integer, values]
    option :filter, ::Types::Strict::Hash, reader: :private, default: proc {
      { "Group Type (code)" => EstablishmentGroupType.all.map(&:code) }
    }

    # ...
    #
    # @return [?]
    def call
      ::Support::EstablishmentGroups::Information.new(filter:, file: data, exporter: export_proc).call
      # TODO: report something useful for the task or job
    end

  private

    # @return [Proc] Wrap a function to complete the pipeline
    def export_proc
      ->(orgs) { saver.call(orgs) }
    end
  end
end
