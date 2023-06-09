module Support
  class EmailTemplateAttachment < ApplicationRecord
    has_one_attached :file
    belongs_to :template, class_name: "Support::EmailTemplate", optional: true

    before_save :update_file_attributes

  private

    def update_file_attributes
      return unless file.new_record?

      self.file_name = file.filename
      self.file_size = file.attachment.byte_size
      self.file_type = file.attachment.content_type
    end
  end
end
