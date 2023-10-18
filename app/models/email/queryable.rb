module Email::Queryable
  extend ActiveSupport::Concern

  included do
    scope :in_conversation, ->(email) { where(outlook_conversation_id: email.outlook_conversation_id) }
    scope :assigned_to_ticket, -> { where.not(case_id: nil) }
    scope :unread, -> { where(is_read: false) }
  end

  def in_current_conversation
    self.class.in_conversation(self).order("sent_at ASC")
  end
end
