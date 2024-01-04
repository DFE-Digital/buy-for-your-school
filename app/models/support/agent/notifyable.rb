module Support::Agent::Notifyable
  extend ActiveSupport::Concern

  included do
    has_many :assigned_to_notifications, class_name: "Support::Notification", inverse_of: :assigned_to do
      def mark_as_read
        where(read: false).update_all(read: true, read_at: Time.zone.now)
      end
    end
  end
end
