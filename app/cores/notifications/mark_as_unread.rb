module Notifications
  class MarkAsUnread
    def call(support_notification_id:)
      notification = Support::Notification.find(support_notification_id)
      notification.update!(read: false, read_at: nil)
    end
  end
end
