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

    option :file,       optional: true, type: ::Types.Constructor(File)
    # @see Exporter
    option :exporter,   optional: true

    option :mapper,     default: proc { Mapper.new }
    option :schema,     default: proc { Schema.new }
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
      mapper.call(tuples)
    end

    # @return [Enumerator] table rows
    def tuples
      CSV.foreach(data_file.path, headers: true, encoding: "ISO-8859-1:UTF-8")
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
