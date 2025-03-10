module Email::Actionable
  extend ActiveSupport::Concern

  included do
    after_update_commit :set_ticket_action_required, if: :is_read_previously_changed?
  end

  def set_ticket_action_required
    action_required = if Flipper.enabled?(:sc_tasklist_case)
                        procops_action_required?
                      else
                        default_action_required?
                      end

    ticket.update!(action_required:)
  end

  def procops_action_required?
    unread_emails = Email.where(ticket:, is_read: false).any?
    pending_evaluations = Support::Evaluator.where(support_case_id: ticket.id, has_uploaded_documents: true, evaluation_approved: false).any?
    unread_emails || pending_evaluations
  end

  def default_action_required?
    Email.where(ticket:, is_read: false).any?
  end
end
