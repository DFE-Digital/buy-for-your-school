module Support
  class Email < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", optional: true

    scope :display_order, -> { order("sent_at DESC") }
    scope :my_cases, ->(agent) { where(case_id: agent.case_ids) }

    enum folder: { inbox: 0, sent_items: 1 }

    def self.from_message(message, folder: :inbox)
      email = find_or_initialize_by(
        outlook_id: message.id,
        outlook_conversation_id: message.conversation_id,
      )
      email.update!(
        folder: folder,
        subject: message.subject,
        is_read: message.is_read,
        is_draft: message.is_draft,
        has_attachments: message.has_attachments,
        body_preview: message.body_preview,
        body: message.body.content,
        received_at: message.received_date_time,
        sent_at: message.sent_date_time,
        sender: { address: message.from.email_address.address, name: message.from.email_address.name },
        recipients: message.to_recipients.map(&:email_address).map do |email_address|
          { address: email_address.address, name: email_address.name }
        end,
      )
    end
  end
end
