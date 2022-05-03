module Support
  module Messages
    module Outlook
      module Synchronisation
        module Steps
          class PersistEmail
            def self.call(message, email)
              email.update!(
                folder:                  message.inbox? ? :inbox : :sent_items,
                sender:                  message.sender,
                recipients:              message.recipients,
                outlook_conversation_id: message.conversation_id,
                subject:                 message.subject,
                body:                    message.body.content,
                received_at:             message.received_date_time,
                sent_at:                 message.sent_date_time,
              )
            end
          end
        end
      end
    end
  end
end
