module Support
  class EmailAttachment < ApplicationRecord
    has_one_attached :file
    belongs_to :email, class_name: "Support::Email"

    before_save :update_file_attributes

  private

    def update_file_attributes
      self.file_name = file.filename
      self.file_size = file.attachment.byte_size
      self.file_type = file.attachment.content_type
    end
  end
end
