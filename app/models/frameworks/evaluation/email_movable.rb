module Frameworks::Evaluation::EmailMovable
  extend ActiveSupport::Concern

  def receive_emails_from(ticket:)
    transaction do
      ticket.emails.update_all(ticket_id: id, ticket_type: self.class.name)
      log_emails_moved_from(ticket.id, ticket.class.name)
      update!(action_required: emails.any? { |email| !email.is_read? })
    end
  end

protected

  def log_emails_moved_from(source_id, source_type)
    log_activity_event("emails_moved_from", source_id:, source_type:)
  end
end
