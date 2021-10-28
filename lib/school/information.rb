require "dry-initializer"
require "csv"

require "downloader"
require "types"
require "school/mapper"
require "school/schema"

# https://github.com/DFE-Digital/gias-query-tool/tree/master/dml/geo
#
# Import GIAS data and export (optional function)
#
#
module School
  GIAS_URL = "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public".freeze

  class Information
    extend Dry::Initializer

    # @param file [String, File] optional path to CSV data
    option :file, optional: true, type: ::Types.Constructor(File)

    # @param filter [Hash] select rows by code value
    #
    #   { "Header (code)" => [desirable, integer, values] }
    #
    option :filter, optional: true, type: ::Types::Strict::Hash

    # @see Exporter
    option :exporter, optional: true

    option :mapper, default: proc { Mapper.new }
    option :schema, default: proc { Schema.new }
    option :downloader, default: proc { ::Downloader.new }

    # @return [Array<Hash>]
    def call
      exporter ? exporter.call(coerced_data) : coerced_data
    end

  private

    # @return [Array<Hash>]
    def coerced_data
      structured_data.map { |school| schema.call(school).to_h }
    end

    # @return [Array<Hash>]
    def structured_data
      filter ? map_data(filtered_data) : map_data(tuples)
    end

    # This method can get very memory intensive once past a few thousand records
    # Slicing the data up and forcing the garbage collector to run
    # keeps the memory use low (~20MB) and stops the process from failing
    def map_data(data)
      processed_data = []
      data.each_slice(1000) do |slice|
        processed_data += mapper.call(slice)
        GC.start
      end

      processed_data
    end

    # @return [Enumerator::Lazy] table rows
    def tuples
      CSV.foreach(data_file.path, headers: true, encoding: "ISO-8859-1:UTF-8").lazy
    end

    # @return [Array<Hash>] filter criteria matches the row
    def filtered_data
      tuples.select do |row|
        filter.any? { |key, values| values.include?(row[key].to_i) }
      end
    end

    # @return [File] existing or downloaded data
    def data_file
      file || downloader.call(gias_csv_url)
    end

    # @return [String] url to GIAS public data in CSV format
    def gias_csv_url
      "#{GIAS_URL}/edubasealldata#{date_format}.csv"
    end

    # @return [String] current date "20211014"
    def date_format
      Time.zone.now.strftime("%Y%m%d")
    end
  end
end
