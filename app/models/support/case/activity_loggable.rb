module Support::Case::ActivityLoggable
  extend ActiveSupport::Concern

  included do
    has_many :activity_log_items, class_name: "Support::ActivityLogItem", foreign_key: "support_case_id"

    def previous_state_of(action)
      activity_log_items.where(action:).order(created_at: :asc).last.try(:data) || {}
    end
  end
end
