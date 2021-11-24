module Support
  # Capture activity metrics for cases
  #
  # @see Support::RecordAction

  class ActivityLogItem < ApplicationRecord
    include Csvable

    default_scope { order(:created_at) }

    validates :support_case_id, :action, presence: true
  end
end
