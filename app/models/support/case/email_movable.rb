module Support::Case::EmailMovable
  extend ActiveSupport::Concern

  def email_mover(params = {})
    Support::Case::EmailMover.new(source: self, **params)
  end

  def move_emails_to(ticket:)
    transaction do
      ticket.receive_interactions_from(ticket: self) if ticket.is_a?(Support::Case)
      ticket.receive_emails_from(ticket: self)
      interactions.email_merge.build(
        body: "to ##{ticket.ref}",
        agent_id: Current.actor.id,
      )
      update!(action_required: false)
      Support::ChangeCaseState.new(
        kase: self,
        agent: Current.actor,
        to: :close,
        reason: :email_merge,
        info: ". Email(s) moved to case ##{ticket.ref}",
      ).call
    end
  end

  def receive_emails_from(ticket:)
    transaction do
      ticket.emails.update_all(ticket_id: id, ticket_type: self.class.name)
      interactions.email_merge.build(
        body: "from ##{ticket.ref}",
        agent_id: Current.actor.id,
      )
      update!(action_required: emails.any? { |email| !email.is_read? })
    end
  end

  def receive_interactions_from(ticket:)
    ticket.interactions.update_all(case_id: id)
  end
end
