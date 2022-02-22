module Support
  class EmailAttachment < ApplicationRecord
    has_one_attached :file
    belongs_to :email, class_name: "Support::Email"

    before_save :update_file_attributes

    scope :inline, -> { where(is_inline: true) }

    def self.import_attachment(attachment, email)
      email_attachment = email.attachments.find_or_initialize_by(outlook_id: attachment.id)
      email_attachment.import_from_ms_attachment(attachment)
    end

    def import_from_ms_attachment(attachment)
      Tempfile.create(attachment.name, binmode: true) do |f|
        f.write(Base64.decode64(attachment.content_bytes))
        f.rewind

        file.attach(io: f, filename: attachment.name)

        update!(
          is_inline: attachment.is_inline,
          content_id: attachment.content_id,
        )
      end
    end

  private

    def update_file_attributes
      return unless file.new_record?

      self.file_name = file.filename
      self.file_size = file.attachment.byte_size
      self.file_type = file.attachment.content_type
    end
  end
end
