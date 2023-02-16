module Notifications
  class MarkAllAsRead
    def call(assigned_to_id:)
      Support::Notification.where(assigned_to_id:, read: false).update_all(read: true, read_at: Time.zone.now)
    end
  end
end
