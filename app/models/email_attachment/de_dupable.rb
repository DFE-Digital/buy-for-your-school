module EmailAttachment::DeDupable
  extend ActiveSupport::Concern

  included do
    scope :unique_files, lambda {
      unique_attachments = map { |att| all_instances(att).order("created_at DESC").first }.uniq
      where(id: unique_attachments)
    }

    scope :all_instances, lambda { |email_attachment|
      joins(file_attachment: :blob)
      .where("active_storage_blobs.checksum = ?", email_attachment.checksum)
      .where("active_storage_blobs.filename = ?", email_attachment.file_name)
    }
  end

  class_methods do
    def find_duplicates_of(email_attachment)
      for_ticket(ticket_id: email_attachment.ticket_id)
      .all_instances(email_attachment)
    end
  end
end
