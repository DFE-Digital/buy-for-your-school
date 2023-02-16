module Support
  class Notification < ApplicationRecord
    belongs_to :support_case, class_name: "Support::Case", optional: true
    belongs_to :assigned_to, class_name: "Support::Agent"
    belongs_to :assigned_by, class_name: "Support::Agent", optional: true

    enum :topic, {
      case_assigned: 0,
    }

    scope :unread, ->(assigned_to:) { where(assigned_to:, read: false) }
    scope :feed, ->(assigned_to:) { where(assigned_to:).order("created_at DESC") }

    after_create_commit lambda { |notification|
      broadcast_render_to(
        [notification.assigned_to, "notifications"],
        partial: "support/notifications/stream_events/notification_received",
        locals: {
          notifications_unread: true,
          agent: notification.assigned_to,
          notification:,
        },
      )
    }

    def case_ref = support_case.ref
    def case_created = support_case.created_at
    def assigned_by_name = assigned_by.full_name
    def received_at = created_at
  end
end
