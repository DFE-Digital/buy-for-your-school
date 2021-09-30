# Capture user activity metrics
#
# @see RecordAction
class ActivityLogItem < ApplicationRecord
  self.table_name = "activity_log"

  validates :user_id, :journey_id, :action, presence: true
end
