module Energy
  module SupportDocumentsHelper
    def attach_documents_to_support_case(documents, support_case)
      documents.each do |document_path|
        support_case.case_attachments.create!(
          attachable: support_document(document_path, support_case),
          custom_name: File.basename(document_path),
          description: "System uploaded document",
        )
      end
    end

    def delete_temp_files(documents)
      documents.each do |document_path|
        File.delete(document_path) if File.exist?(document_path)
      end
    end

  private

    def support_document(document_path, support_case)
      xl_document = File.open(document_path)
      Support::Document.create!(
        case: support_case,
        file_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        file: xl_document,
      )
    end
  end
end
