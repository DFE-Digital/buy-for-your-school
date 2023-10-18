class MessageThread < ApplicationRecord
  self.primary_key = :conversation_id
  self.table_name = "support_message_threads"

  has_many :messages, -> { order("sent_at ASC") }, class_name: "Email", foreign_key: :outlook_conversation_id
  belongs_to :ticket, polymorphic: true

  default_scope { order(last_updated: :desc) }

  def last_received_reply
    messages.inbox.last
  end
end
