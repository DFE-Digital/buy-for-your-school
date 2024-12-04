module Support::Case::DocumentUploadable
  extend ActiveSupport::Concern

  def document_uploader(params = {})
    Support::Case::DocumentUploader.new(support_case: self, **params)
  end

  def upload_document_files(files:)
    return if files.blank?

    files.each do |file|
      upload_documents.create!(
        attachable: Support::Document.create!(case: self, file_type: file.content_type, file:),
        file_type: file.content_type,
        file_name: file.original_filename,
        file_size: file.size,
      )
    end
  end
end
