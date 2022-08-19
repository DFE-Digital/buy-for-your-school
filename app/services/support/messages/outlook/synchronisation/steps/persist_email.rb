module Support
  module Messages
    module Outlook
      module Synchronisation
        module Steps
          class PersistEmail
            def self.call(message, email)
              email.update!(
                outlook_id: message.id,
                folder: message.inbox? ? :inbox : :sent_items,
                sender: message.sender,
                recipients: message.recipients,
                subject: message.subject,
                body: message.body.content,
                unique_body: message.unique_body&.content,
                sent_at: message.sent_date_time,
                outlook_conversation_id: message.conversation_id,
                outlook_received_at: message.received_date_time,
                outlook_has_attachments: message.has_attachments,
                outlook_is_read: message.is_read,
                outlook_is_draft: message.is_draft,
                in_reply_to_id: message.in_reply_to_id,
              )
            end
          end
        end
      end
    end
  end
end
