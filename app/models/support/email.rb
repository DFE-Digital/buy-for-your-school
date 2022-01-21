module Support
  class Email < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", optional: true
    has_many   :attachments, class_name: "Support::EmailAttachment"

    scope :display_order, -> { order("sent_at DESC") }
    scope :my_cases, ->(agent) { where(case_id: agent.case_ids) }
    scope :unread, -> { where(is_read: false) }

    enum folder: { inbox: 0, sent_items: 1 }

    def self.import_from_mailbox(message, folder: :inbox)
      email = find_or_initialize_by(outlook_id: message.id)
      is_first_import = email.new_record?

      email.import_from_message(message, folder: folder)
      email.automatically_assign_case
      email.create_interaction
      email.set_case_action_required if is_first_import
    end

    def import_from_message(message, folder: :inbox)
      update!(
        outlook_id: message.id,
        outlook_conversation_id: message.conversation_id,
        folder: folder,
        subject: message.subject,
        outlook_is_read: message.is_read,
        is_draft: message.is_draft,
        has_attachments: message.has_attachments,
        body_preview: message.body_preview,
        body: message.body.content,
        received_at: message.received_date_time,
        sent_at: message.sent_date_time,
        sender: {
          address: message.from.email_address.address,
          name: message.from.email_address.name,
        },
        recipients: message.to_recipients.map(&:email_address).map do |email_address|
          {
            address: email_address.address,
            name: email_address.name,
          }
        end,
      )
      IncomingEmails::EmailAttachments.download(email: self) if message.has_attachments
    end

    def automatically_assign_case
      return if case_id.present?

      Support::IncomingEmails::CaseAssignment.detect_and_assign_case(self)

      save!
    end

    def create_interaction
      return if self.case.blank?

      case_interactions = self.case.interactions
        .send("email_#{inbox? ? 'from' : 'to'}_school")
        .where("additional_data->>'email_id' = ?", id)

      unless case_interactions.any?
        case_interactions.create!(
          body: body,
          additional_data: { email_id: id },
          created_at: sent_at,
        )
      end

      save!
    end

    def set_case_action_required
      self.case.update!(action_required: true) if self.case.present?
    end
  end
end
