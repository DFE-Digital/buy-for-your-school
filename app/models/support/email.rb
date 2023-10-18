module Support
  class Email < ::Email
    scope :display_order, -> { order("sent_at DESC") }
    scope :my_cases, ->(agent) { where(ticket_id: agent.case_ids) }

    def case = ticket

    def case=(ticket)
      self.ticket = ticket
    end
  end
end
