module Support
  class MessageThread < ApplicationRecord
    self.primary_key = :conversation_id

    has_many :messages, class_name: "Support::Email", foreign_key: :outlook_conversation_id

    default_scope { order(last_updated: :desc) }
  end
end
