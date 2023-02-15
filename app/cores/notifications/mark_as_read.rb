module Notifications
  class MarkAsRead
    def call(support_notification_id:)
      notification = Support::Notification.find(support_notification_id)
      notification.update!(read: true, read_at: Time.zone.now)
    end
  end
end
