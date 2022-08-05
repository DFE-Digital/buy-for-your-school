module Support
  class MessageThread < ApplicationRecord
    self.primary_key = :conversation_id

    default_scope { order(last_updated: :desc) }

    def messages
      Support::Email.find_by(outlook_conversation_id: conversation_id)
    end
  end
end
