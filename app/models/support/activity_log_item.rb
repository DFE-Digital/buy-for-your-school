module Support
  # Capture activity metrics for cases
  #
  # @see RecordSupportCaseAction

  class ActivityLogItem < ApplicationRecord
    validates :support_case_id, :action, presence: true
  end
end
