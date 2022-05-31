module Support
  module Messages
    module Outlook
      module Synchronisation
        module Steps
          class PersistEmailAttachments
            def self.call(message, email)
              message.attachments.each do |message_attachment|
                MessageAttachmentImporter.call(message_attachment, email)
              end
            end
          end
        end
      end
    end
  end
end
