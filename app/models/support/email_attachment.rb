module Support
  class EmailAttachment < ApplicationRecord
    has_one_attached :file
    belongs_to :email, class_name: "Support::Email"

    before_save :update_file_attributes

    scope :inline, -> { where(is_inline: true) }
    scope :non_inline, -> { where(is_inline: false) }
    scope :for_case_attachments, -> { where(file_type: CASE_ATTACHMENT_FILE_TYPE_ALLOW_LIST) }

    def name = custom_name.presence || file_name

    def self.unique_files_for_case(case_id:)
      select("DISTINCT ON (active_storage_blobs.checksum, support_email_attachments.is_inline) support_email_attachments.*")
        .joins('JOIN active_storage_attachments
          ON active_storage_attachments.record_type = \'Support::EmailAttachment\'
          AND active_storage_attachments.record_id = support_email_attachments.id')
        .joins("JOIN active_storage_blobs ON active_storage_blobs.id = active_storage_attachments.blob_id")
        .joins(:email)
        .where(email: { case_id: })
        .order(is_inline: :asc)
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
