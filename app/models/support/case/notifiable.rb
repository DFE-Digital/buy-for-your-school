module Support::Case::Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, class_name: "Support::Notification", foreign_key: :support_case_id
  end

  def notify_agent_of_email_received(email)
    notifications.case_email_recieved.find_or_create_by!(
      support_case: self,
      assigned_to: agent,
      assigned_by_system: true,
      subject: email,
      created_at: email.outlook_received_at,
    )
  end
end
