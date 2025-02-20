module Support::Case::Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, class_name: "Support::Notification", foreign_key: :support_case_id
  end

  def notify_agent_of_email_received(email)
    notifications.case_email_received.find_or_create_by!(
      support_case: self,
      assigned_to: agent,
      assigned_by_system: true,
      subject: email,
      created_at: email.outlook_received_at,
    )
  end

  def notify_agent_of_case_reopened
    notifications.case_reopened.find_or_create_by!(
      support_case: self,
      assigned_to: agent,
      assigned_by_system: true,
      subject: self,
      created_at: updated_at,
    )
  end

  def notify_agent_of_case_closed
    notifications.case_closed.find_or_create_by!(
      support_case: self,
      assigned_to: agent,
      assigned_by_system: true,
      subject: self,
      created_at: updated_at,
    )
  end
end
