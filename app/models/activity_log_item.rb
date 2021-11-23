require "csv"

# Capture user activity metrics
#
# @see RecordAction
class ActivityLogItem < ApplicationRecord
  self.table_name = "activity_log"

  validates :user_id, :journey_id, :action, presence: true

  # @return [String]
  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << column_names

      all.order(:created_at).each do |record|
        csv << record.attributes.values
      end
    end
  end
end
