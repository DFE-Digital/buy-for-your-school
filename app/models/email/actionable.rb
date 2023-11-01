module Email::Actionable
  extend ActiveSupport::Concern

  included do
    after_update_commit :set_ticket_action_required, if: :is_read_previously_changed?
  end

  def set_ticket_action_required
    ticket.update!(action_required: Email.where(ticket:, is_read: false).any?)
  end
end
