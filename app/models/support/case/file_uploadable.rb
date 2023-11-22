module Support::Case::FileUploadable
  extend ActiveSupport::Concern

  def file_uploader(params = {})
    Support::Case::FileUploader.new(support_case: self, **params)
  end

  def upload_files(files:)
    files.each do |file|
      case_attachments.create!(
        attachable: Support::Document.create!(case: self, file_type: file.content_type, file:),
        custom_name: file.original_filename,
        description: "Agent uploaded document",
      )
    end
  end
end
