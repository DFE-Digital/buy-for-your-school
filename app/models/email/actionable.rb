module Email::Actionable
  extend ActiveSupport::Concern

  included do
    after_update_commit :set_ticket_action_required, if: :is_read_previously_changed?
  end

  def set_ticket_action_required
    if Flipper.enabled?(:sc_notify_procops)
      action_required = Email.where(ticket:, is_read: false).any? || Support::Evaluator.where(support_case_id: ticket.id, has_uploaded_documents: true, evaluation_approved: false).any?
      ticket.update!(action_required:)
    else
      ticket.update!(action_required: Email.where(ticket:, is_read: false).any?)
    end
  end
end
