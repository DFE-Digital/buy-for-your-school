class Email::Draft::Attachable
  ACCEPTABLE_BLOB_TYPES = [
    Support::EmailTemplateAttachment,
  ].freeze

  def self.get_from_blobs(blob_attachments)
    Array(blob_attachments).map do |raw_blob_attachment|
      type = raw_blob_attachment["type"].safe_constantize
      id   = raw_blob_attachment["file_id"]

      next unless type.in?(ACCEPTABLE_BLOB_TYPES) && id.present?

      get(type.find(id))
    end
  end

  def self.get_from_file_attachments(file_attachments)
    Array(file_attachments).map(&method(:get))
  end

  def self.get(attachable)
    case attachable
    when ActionDispatch::Http::UploadedFile then from_uploaded_file(attachable)
    when *ACCEPTABLE_BLOB_TYPES             then from_blob(attachable.file.blob)
    end
  end

  def self.from_uploaded_file(uploaded_file)
    new(
      name: uploaded_file.original_filename,
      content_type: uploaded_file.content_type,
      content_bytes: uploaded_file.tempfile.tap(&:rewind).read,
    )
  end

  def self.from_blob(blob)
    new(
      name: blob.filename,
      content_type: blob.content_type,
      content_bytes: blob.download,
    )
  end

  attr_reader :name, :content_bytes, :content_type

  def initialize(name:, content_bytes:, content_type:)
    @name = name
    @content_bytes = Base64.encode64(content_bytes)
    @content_type = content_type
  end
end
