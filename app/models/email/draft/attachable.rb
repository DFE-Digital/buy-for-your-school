class Email::Draft::Attachable
  def self.get(attachable)
    case attachable
    when ActionDispatch::Http::UploadedFile then from_uploaded_file(attachable)
    when Support::EmailTemplateAttachment   then from_blob(attachable.file.blob)
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
