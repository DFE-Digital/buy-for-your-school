module Support
  class EmailAttachment < ApplicationRecord
    has_one_attached :file
    belongs_to :email, class_name: "Support::Email"

    before_save :update_file_attributes

    scope :inline, -> { where(is_inline: true) }

    def self.import_attachment(attachment, message_ms_id)
      email = Support::Email.find_by(outlook_id: message_ms_id)
      attachment = find_or_initialize_by(content_id: attachment.content_id)

    end

    def import_from_attachment(attachment, email)
      # create AR model and active storage magic
    end

  private

    def update_file_attributes
      self.file_name = file.filename
      self.file_size = file.attachment.byte_size
      self.file_type = file.attachment.content_type
    end
  end
end
