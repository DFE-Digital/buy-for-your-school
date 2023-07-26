module Support
  class EmailAttachment < ApplicationRecord
    include DeDupable
    include Hideable

    has_one_attached :file
    belongs_to :email, class_name: "Support::Email"

    before_save :update_file_attributes

    scope :inline, -> { where(is_inline: true) }
    scope :non_inline, -> { where(is_inline: false) }
    scope :for_case_attachments, -> { where(file_type: CASE_ATTACHMENT_FILE_TYPE_ALLOW_LIST) }
    scope :for_case, ->(case_id:) { joins(:email).where(email: { case_id: }) }

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
