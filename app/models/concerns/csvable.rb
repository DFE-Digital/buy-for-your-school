require "csv"

module Csvable
  extend ActiveSupport::Concern

  included do
    # @return [String]
    def self.to_csv
      CSV.generate(headers: true) do |csv|
        csv << column_names

        find_each do |record|
          csv << record.attributes.values
        end
      end
    end
  end
end
