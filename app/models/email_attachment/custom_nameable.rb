module EmailAttachment::CustomNameable
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_custom_name_has_extension!, if: :custom_name_changed?, on: :update
  end

private

  def ensure_custom_name_has_extension!
    file_extension = ActiveStorage::Filename.new(file_name).extension_with_delimiter
    self.custom_name = custom_name.gsub(file_extension, "").concat(file_extension)
  end
end
