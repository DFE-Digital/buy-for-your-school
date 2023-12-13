module Support::Case::EmailTicketable
  extend ActiveSupport::Concern

  included do
    has_many :emails, as: :ticket, after_add: :on_email_attached

    has_many :email_attachments, class_name: "EmailAttachment", through: :emails, source: :attachments

    has_many :message_threads, class_name: "MessageThread", as: :ticket
  end

  def email_prefix
    "Case #{ref}"
  end

  class_methods do
    def on_email_cached(email)
      ExistingCase.find_or_create_by!(email).emails << email
    end
  end

private

  def on_email_attached(email)
    email.inbox? ? on_incoming_email_attached(email) : on_outgoing_email_attached(email)
  end

  def on_incoming_email_attached(email)
    reopen_due_to_incoming_email! if may_reopen_due_to_incoming_email?

    if email.outlook_received_at.today? && agent.present?
      Support::Notification.case_email_recieved.find_or_create_by!(
        support_case: self,
        assigned_to: agent,
        assigned_by_system: true,
        subject: email,
        created_at: email.outlook_received_at,
      )
    end

    update!(action_required: true)
  end

  def on_outgoing_email_attached(_email)
    hold_due_to_contact_with_school! if may_hold_due_to_contact_with_school?
  end
end
