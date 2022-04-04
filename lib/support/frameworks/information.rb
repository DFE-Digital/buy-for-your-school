require "dry-initializer"
require "csv"

require "types"
require "support/frameworks/mapper"
require "support/frameworks/schema"

module Support
  # Process data from Category team's framework list
  #   1. use local file
  #   2. filter by column and values
  #   3. transform data structure
  #   4. coerce and validate tuples
  #   5. pass to optional function

  module Frameworks
    class Information
      extend Dry::Initializer

      # @!attribute file
      # @return [nil, String, File] path to CSV data
      option :file, type: ::Types::Nil | ::Types.Constructor(File)

      # @!attribute filter
      # @return [Hash] "column header" => [integer, values]
      option :filter, optional: true, type: ::Types::Nil | ::Types::Strict::Hash

      # @see Support::Frameworks::RecordKeeper
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

      # @return [Array<Hash>]
      def call
        output = []

        data.each_slice(batch_size) do |rows|
          dataset = process(rows)
          output << dataset
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
        CSV.foreach(file.path, headers: true, encoding: "UTF-8").lazy
      end

      # Converts "01" to 1
      #
      # @return [Enumerator::Lazy] filter rows by codes
      def filtered_rows
        all_rows.select do |row|
          filter.any? { |key, values| values.include?(row[key].to_i) }
        end
      end
    end
  end
end
