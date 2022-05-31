module Support
  module Messages
    module Outlook
      module Synchronisation
        module Steps
          class PersistEmail
            def self.call(message, email)
              email.update!(
                outlook_id: message.id,
                case_reference_from_headers: message.case_reference_from_headers,
                replying_to_id: message.replying_to_email_from_headers,
                folder: message.inbox? ? :inbox : :sent_items,
                sender: message.sender,
                recipients: message.recipients,
                subject: message.subject,
                body: message.body.content,
                sent_at: message.sent_date_time,
                outlook_conversation_id: message.conversation_id,
                outlook_received_at: message.received_date_time,
                outlook_has_attachments: message.has_attachments,
                outlook_is_read: message.is_read,
                outlook_is_draft: message.is_draft,
              )
            end
          end
        end
      end
    end
  end
end
