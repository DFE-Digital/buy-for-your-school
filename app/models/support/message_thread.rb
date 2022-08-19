module Support
  class MessageThread < ApplicationRecord
    self.primary_key = :conversation_id

    has_many :messages, -> { order("sent_at ASC") }, class_name: "Support::Email", foreign_key: :outlook_conversation_id
    belongs_to :case, class_name: "Support::Case"

    default_scope { order(last_updated: :desc) }

    def last_received_reply
      messages.inbox.last
    end
  end
end
