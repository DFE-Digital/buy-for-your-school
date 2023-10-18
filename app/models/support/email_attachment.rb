module Support
  class EmailAttachment < ::EmailAttachment
    include DeDupable
    include Hideable

    belongs_to :email, class_name: "Support::Email"

    scope :for_case_attachments, -> { where(file_type: CASE_ATTACHMENT_FILE_TYPE_ALLOW_LIST) }
    scope :for_case, ->(case_id:) { joins(:email).where(email: { ticket_id: case_id }) }

    delegate :case, :case_id, :ticket_id, to: :email

    def custom_name = super.presence || file_name
    def checksum = file.attachment.blob.checksum
  end
end
