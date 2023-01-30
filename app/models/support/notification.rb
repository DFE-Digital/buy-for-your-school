module Support
  class Notification < ApplicationRecord
    has_many :assignments, class_name: "Support::NotificationAssignment", foreign_key: :support_notification_id
  end
end
