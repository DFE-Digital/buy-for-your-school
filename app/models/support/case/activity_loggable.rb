module Support::Case::ActivityLoggable
  extend ActiveSupport::Concern

  included do
    has_many :activity_log_items, class_name: "Support::ActivityLogItem", foreign_key: "support_case_id"
  end
end
