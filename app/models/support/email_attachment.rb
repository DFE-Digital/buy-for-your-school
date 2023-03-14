module Support
  class EmailAttachment < ApplicationRecord
    has_one_attached :file
    belongs_to :email, class_name: "Support::Email"

    before_save :update_file_attributes

    scope :inline, -> { where(is_inline: true) }
    scope :non_inline, -> { where(is_inline: false) }
    scope :for_case_attachments, -> { where(file_type: CASE_ATTACHMENT_FILE_TYPE_ALLOW_LIST) }
    scope :for_case, ->(case_id:) { joins(:email).where(email: { case_id: }) }
    scope :unique_files, lambda { |first_instance_only: true|
      joins(
        <<-SQL,
        INNER JOIN (
          SELECT
            support_email_attachments.id,
            active_storage_blobs.checksum,
            ROW_NUMBER() OVER(
              PARTITION BY active_storage_blobs.checksum, active_storage_blobs.filename
              ORDER BY support_email_attachments.updated_at DESC
            ) AS rank
          FROM support_email_attachments
          JOIN active_storage_attachments
            ON active_storage_attachments.record_type = 'Support::EmailAttachment'
            AND active_storage_attachments.record_id = support_email_attachments.id
          JOIN active_storage_blobs
            ON active_storage_blobs.id = active_storage_attachments.blob_id
        ) attachment_files
        ON attachment_files.id = support_email_attachments.id
        #{'AND attachment_files.rank = 1' if first_instance_only}
      SQL
      )
    }

    def self.find_duplicates_of(email_attachment)
      unique_files(first_instance_only: false)
        .for_case(case_id: email_attachment.case_id)
        .where(attachment_files: { checksum: email_attachment.checksum }, file_name: email_attachment.file_name)
    end

    delegate :case, :case_id, to: :email

    def custom_name = super.presence || file_name
    def checksum = file.attachment.blob.checksum

  private

    def update_file_attributes
      return unless file.new_record?

      self.file_name = file.filename
      self.file_size = file.attachment.byte_size
      self.file_type = file.attachment.content_type
    end
  end
end
