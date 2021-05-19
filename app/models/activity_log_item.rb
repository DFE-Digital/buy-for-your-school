class ActivityLogItem < ApplicationRecord
  self.implicit_order_column = "created_at"
  self.table_name = "activity_log"
end
