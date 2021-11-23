# Capture user activity metrics for cases
#
# @see RecordSupportCaseAction

module Support
  class ActivityLogItem < ApplicationRecord
    validates :support_case_id, :action, presence: true
  end
end
