require "dry-initializer"
require "csv"

require "types"
require "support/establishment_groups/mapper"
require "support/establishment_groups/schema"

module Support
  # "GIAS" formerly called "Edubase"
  GIAS_URL = "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public".freeze

  # Batch process data from "Get Information About Schools"
  #   1. use local file or download
  #   2. filter by column and values
  #   3. transform data structure
  #   4. coerce and validate tuples
  #   5. pass to optional function

  module EstablishmentGroups
    class Information
      extend Dry::Initializer

      # @!attribute file
      # @return [nil, String, File] optional path to CSV data
      option :file, optional: true, type: ::Types::Nil | ::Types.Constructor(File)

      # @!attribute filter
      # @return [Hash] "column header" => [integer, values]
      option :filter, optional: true, type: ::Types::Strict::Hash

      # @see Exporter
      # @see Support::EstablishmentGroups::RecordKeeper
      #
      # @!attribute exporter
      # @return [Proc] (defaults to "->(x = nil) { x }")
      option :exporter, default: proc { ->(x = nil) { x } }

      # Restricts how much memory is consumed by data manipulation
      #
      # @!attribute batch_size
      # @return [Integer] iterate over records in batches (defaults to 1_000)
      option :batch_size, default: proc { 1_000 }, type: ::Types::Strict::Integer

      # @!attribute mapper
      # @return [Mapper] (defaults to new instance)
      option :mapper, default: proc { Mapper.new }

      # @!attribute schema
      # @return [Schema] (defaults to new instance)
      option :schema, default: proc { Schema.new }

      # @!attribute downloader
      # @return [Downloader] (defaults to new instance)
      option :downloader, default: proc { ::Downloader.new }

      # @return [Array<Hash>]
      def call
        output = []

        data.each_slice(batch_size) do |rows|
          dataset = process(rows)
          output << dataset # if we wish to return the entries (kept to keep specs passing)
          exporter.call dataset
        end

        output.flatten
      end

    private

      # @return [Array<Hash>] transformed and coerced data
      def process(rows)
        mapper.call(rows).map { |row| schema.call(row).to_h }
      end

      # @return [Enumerator::Lazy]
      def data
        filter ? filtered_rows : all_rows
      end

      # @return [Enumerator::Lazy] table rows
      def all_rows
        CSV.foreach(data_file.path, headers: true, encoding: "ISO-8859-1:UTF-8").lazy
      end

      # Converts "01" to 1
      #
      # @return [Enumerator::Lazy] filter rows by codes
      def filtered_rows
        all_rows.select do |row|
          # OPTIMIZE: filter GIAS data by any column not just codes
          filter.any? { |key, values| values.include?(row[key].to_i) }
        end
      end

      # @return [File] existing or downloaded data
      def data_file
        file || downloader.call(establishment_groups_csv_url)
      end

      # @return [String] url to GIAS establishment group data in CSV format
      def establishment_groups_csv_url
        "#{GIAS_URL}/allgroupsdata#{date_format}.csv"
      end

      # @return [String] current date "20211014"
      def date_format
        Time.zone.now.strftime("%Y%m%d")
      end
    end
  end
end
