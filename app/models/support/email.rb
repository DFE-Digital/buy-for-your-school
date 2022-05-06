module Support
  class Email < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", optional: true
    belongs_to :replying_to, class_name: "Support::Email", optional: true
    has_many   :replies, class_name: "Support::Email", foreign_key: :replying_to_id
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
