require "csv"

module Support
  # Capture activity metrics for cases
  #
  # @see Support::RecordAction

  class ActivityLogItem < ApplicationRecord
    default_scope { order(:created_at) }

    validates :support_case_id, :action, presence: true

    belongs_to :support_case, class_name: "Support::Case"

    # @return [String]
    def self.to_csv
      CSV.generate(headers: true) do |csv|
        csv << column_names

        find_each { |record| csv << record.attributes.values }
      end
    end
  end
end
