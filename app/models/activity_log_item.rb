require "csv"

# Capture user activity metrics
#
# @see RecordAction
class ActivityLogItem < ApplicationRecord
  include Csvable

  self.table_name = "activity_log"

  default_scope { order(:created_at) }

  validates :user_id, :journey_id, :action, presence: true
end
