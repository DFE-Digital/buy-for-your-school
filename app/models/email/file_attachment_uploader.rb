class Email::FileAttachmentUploader
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :email
  attribute :file

  validates :email, presence: true
  validates :file, presence: true
  validate :file_safe, if: -> { file.present? }

  def save!
    email.attachments.create(
      file_name: file.original_filename,
      file_type: file.content_type,
      file_size: file.size,
      file:,
    )
  end

private

  def file_safe
    result = Support::VirusScanner.uploaded_file_safe?(file)
    errors.add(:file, "virus detected") unless result
  end
end
