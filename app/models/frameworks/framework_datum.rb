require "csv"

module Frameworks
  class FrameworkDatum < ApplicationRecord
    self.primary_key = :framework_id

    # Since these are all coming from other records, there is a risk of method collision
    # To avoid this, prefixes are used
    enum :source, Framework.sources, prefix: :framework
    enum :status, Framework.statuses, prefix: :framework
    enum :lot, Framework.lots, prefix: :framework

    def readonly?
      true
    end

    # @return [String]
    def self.to_csv
      CSV.generate(headers: true) do |csv|
        csv << column_names

        find_each { |record| csv << record.attributes.values }
      end
    end
  end
end
