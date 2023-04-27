module Support
  class Email < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", optional: true
    belongs_to :template, class_name: "Support::EmailTemplate", optional: true
    belongs_to :thread, class_name: "Support::MessageThread", primary_key: :conversation_id, foreign_key: :outlook_conversation_id, optional: true
    has_one    :in_reply_to, class_name: "Support::Email", foreign_key: :outlook_internet_message_id, primary_key: :in_reply_to_id
    has_many   :replies, class_name: "Support::Email", foreign_key: :in_reply_to_id, primary_key: :outlook_internet_message_id
    has_many   :attachments, class_name: "Support::EmailAttachment"

    scope :display_order, -> { order("sent_at DESC") }
    scope :my_cases, ->(agent) { where(case_id: agent.case_ids) }
    scope :unread, -> { where(is_read: false) }

    enum folder: { inbox: 0, sent_items: 1 }

    def has_unattachable_files_attached?
      attachments.for_case_attachments.count < attachments.count
    end
  end
end
