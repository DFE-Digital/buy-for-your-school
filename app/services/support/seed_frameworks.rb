require "yaml"
require "dry-initializer"
require "support/frameworks/information"
require "support/frameworks/record_keeper"

module Support
  #
  # Persist frameworks that the service supports from a CSV file
  #
  # @example
  #   SeedFrameworks.new(data: "/path/to/file.yml").call
  #
  class SeedFrameworks
    extend Dry::Initializer
    # Path to local file
    #
    # @!attribute [r] data
    # @!visibility private
    option :data, reader: :private

    # Persistence logic
    # (defaults to Frameworks::RecordKeeper)
    #
    # @!attribute [r] saver
    # @!visibility private
    option :saver, reader: :private, default: proc { ::Support::Frameworks::RecordKeeper.new }

    # Filter records that do match these criteria
    #
    # @!attribute [r] filter
    # @!visibility private
    # @return [Hash] "column header" => [integer, values]
    option :filter, ::Types::Strict::Hash, reader: :private, optional: true

    # @return [Array<Hash>]
    def call
      ::Support::Frameworks::Information.new(filter:, file: data, exporter: export_proc).call
    end

  private

    # @return [Proc] Wrap a function to complete the pipeline
    def export_proc
      ->(orgs) { saver.call(orgs) }
    end
  end
end
