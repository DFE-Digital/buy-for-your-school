# frozen_string_literal: true

module CaseFiles
  class SubmitCaseUpload
    def call(upload_reference:, support_case_id:)
      uploads = EngagementCaseUpload.where(upload_reference:)

      uploads.update_all(upload_status: :submitted, support_case_id:)

      uploads.each do |upload|
        Support::CaseAttachment.create(
          attachable: upload,
          support_case_id:,
          custom_name: upload.file_name,
          description: "User uploaded attachment",
          created_at: upload.created_at,
          updated_at: upload.updated_at,
        )
      end
    end
  end
end
