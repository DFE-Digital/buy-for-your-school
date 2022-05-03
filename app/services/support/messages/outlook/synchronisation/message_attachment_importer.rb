module Support
  module Messages
    module Outlook
      module Synchronisation
        class MessageAttachmentImporter
          def self.call(message_attachment, email)
            email_attachment = Support::EmailAttachment
              .find_or_initialize_by(email: email, outlook_id: message_attachment.id)

            return unless email_attachment.new_record?

            email_attachment.file.attach(
              io: message_attachment.io,
              filename: message_attachment.name,
              content_type: message_attachment.content_type
            )

            email_attachment.update!(
              is_inline:  message_attachment.is_inline,
              content_id: message_attachment.content_id,
            )
          end
        end
      end
    end
  end
end
