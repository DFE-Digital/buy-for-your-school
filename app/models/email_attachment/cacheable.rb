module EmailAttachment::Cacheable
  extend ActiveSupport::Concern

  included do
    before_create :set_file_metadata
  end

  class_methods do
    def cache_attachments_for_email(email, mailbox: Email.default_mailbox)
      attachments = MicrosoftGraph.client.get_file_attachments(mailbox.user_id, email.outlook_id)
      attachments.each { |attachment| cache_attachment(attachment, email:) }
    end

    def cache_attachment(attachment, email:)
      find_or_create_by(email:, outlook_id: attachment.id) do |email_attachment|
        email_attachment.is_inline = attachment.is_inline
        email_attachment.content_id = attachment.content_id
        email_attachment.file.attach(
          io: StringIO.new(attachment.content_bytes),
          filename: attachment.name,
          content_type: attachment.content_type,
        )
      end
    end
  end

private

  def set_file_metadata
    self.file_name = file.filename
    self.file_size = file.attachment.byte_size
    self.file_type = file.attachment.content_type
  end
end
