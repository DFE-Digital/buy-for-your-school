require "dry-initializer"

require "school/information"
require "school/record_keeper"

module Support
  #
  # Construct a pipeline to import data from GIAS
  # using School::Information and School::RecordKeeper
  # run via rake task or background job to maintain school records
  #
  class SeedSchools
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
    option :saver, reader: :private, default: proc { ::School::RecordKeeper.new }

    # Filter records that do match these criteria
    #
    # @!attribute [r] filter
    # @!visibility private
    # @return [Hash] "column header" => [integer, values]
    option :filter, ::Types::Strict::Hash, reader: :private, default: proc {
      { "TypeOfEstablishment (code)" => EstablishmentType.all.map(&:code) }
    }

    # ...
    #
    # @return [?]
    def call
      ::School::Information.new(filter:, file: data, exporter: export_proc).call
      # TODO: report something useful for the task or job
    end

  private

    # @return [Proc] Wrap a function to complete the pipeline
    def export_proc
      ->(orgs) { saver.call(orgs) }
    end
  end
end
