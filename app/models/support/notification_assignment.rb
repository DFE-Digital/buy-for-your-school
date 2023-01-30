module Support
  class NotificationAssignment < ApplicationRecord
    belongs_to :notification, class_name: "Support::Notification", foreign_key: :support_notification_id
    belongs_to :assigned_to, class_name: "Support::Agent"
    belongs_to :assigned_by, class_name: "Support::Agent", optional: true

    scope :default_order, -> { order("support_notification_assignments.created_at DESC") }
    scope :feed, ->(agent:) { default_order.where(assigned_to: agent).includes(:notification) }

    def self.assign(notification:, to:, **assignment)
      create!(notification:, assigned_to: to, **assignment)
    end

    def mark_as_read!
      update!(read: true, read_at: Time.zone.now)
    end
  end
end
