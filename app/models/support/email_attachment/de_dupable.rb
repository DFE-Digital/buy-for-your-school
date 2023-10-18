module Support::EmailAttachment::DeDupable
  extend ActiveSupport::Concern

  included do
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
            ON active_storage_attachments.record_id = support_email_attachments.id
          JOIN active_storage_blobs
            ON active_storage_blobs.id = active_storage_attachments.blob_id
        ) attachment_files
        ON attachment_files.id = support_email_attachments.id
        #{'AND attachment_files.rank = 1' if first_instance_only}
      SQL
      )
    }
  end

  class_methods do
    def find_duplicates_of(email_attachment)
      unique_files(first_instance_only: false)
        .for_ticket(ticket_id: email_attachment.ticket_id)
        .where(attachment_files: { checksum: email_attachment.checksum },
               file_name: email_attachment.file_name)
    end
  end
end
