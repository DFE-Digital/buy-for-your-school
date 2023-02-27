module Notifications
  class HandleMessages
    def received_email_attached_to_case(payload)
      support_email = Support::Email.find(payload[:support_email_id])
      support_case = Support::Case.find(payload[:support_case_id])

      return unless support_email.outlook_received_at.today? && support_case.agent.present?

      Support::Notification.case_email_recieved.find_or_create_by!(
        support_case:,
        assigned_to: support_case.agent,
        assigned_by_system: true,
        subject: support_email,
        created_at: support_email.outlook_received_at,
      )
    end
  end
end
