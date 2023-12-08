class Email::BlobAttachmentPicker
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  ACCEPTABLE_BLOB_TYPES = [
    EmailAttachment,
    Support::CaseAttachment,
  ].freeze

  attribute :email
  attribute :attachments, default: -> { [] }

  validates :email, presence: true
  validates :attachments, presence: { message: "Select files to attach" }

  def initialize(attributes = {})
    super
    self.attachments = attachments.compact_blank.excluding("all")
  end

  def save!
    email.attachments.push(*parse_attachments)
    email.save!
  end

private

  def parse_attachments
    parsed_attachments = []
    attachments.each do |attachment|
      parsed = JSON.parse(attachment)
      type = parsed["type"].safe_constantize
      id   = parsed["file_id"]

      next unless type.in?(ACCEPTABLE_BLOB_TYPES) && id.present?

      parsed_attachments << create_new_attachment(type.find(id).file.blob)
    end
    parsed_attachments
  end

  def create_new_attachment(blob)
    attachment = EmailAttachment.new(
      file_name: blob.filename,
      file_type: blob.content_type,
      file_size: blob.byte_size,
    )
    attachment.file.attach(
      io: StringIO.new(blob.download),
      filename: blob.filename,
      content_type: blob.content_type,
    )
    attachment
  end
end
