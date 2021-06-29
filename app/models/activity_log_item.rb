# ActivityLogItem captures user actions with contextual information, such as `user_id`, `journey_id`, etc.
#
# This is used to keep track of actions taken on {Journey}s, {Task}s, {Step}s, and others.
#
# @see RecordAction
class ActivityLogItem < ApplicationRecord
  self.table_name = "activity_log"
end
