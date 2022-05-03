module Support
  class Email < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", optional: true
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
