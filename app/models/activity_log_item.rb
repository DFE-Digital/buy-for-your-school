require "csv"

# Capture user activity metrics
#
# @see RecordAction
class ActivityLogItem < ApplicationRecord
  self.table_name = "activity_log"

  belongs_to :category, foreign_key: "contentful_category_id", primary_key: "contentful_id", optional: true
  belongs_to :section, foreign_key: "contentful_section_id", primary_key: "contentful_id", optional: true
  belongs_to :task, foreign_key: "contentful_task_id", primary_key: "contentful_id", optional: true
  belongs_to :step, foreign_key: "contentful_step_id", primary_key: "contentful_id", optional: true

  default_scope { order(:created_at) }

  validates :user_id, :journey_id, :action, presence: true

  # @return [String]
  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << column_names

      find_each { |record| csv << record.attributes.values }
    end
  end
end
