module Support::Case::DocumentUploadable
  extend ActiveSupport::Concern

  def document_uploader(params = {})
    Support::Case::DocumentUploader.new(support_case: self, **params)
  end

  def upload_document_files(files:)
    return if files.blank?

    files.each do |file|
      uploaded_document = upload_documents.create!(
        attachable: Support::Document.create!(case: self, file_type: file.content_type, file:),
        file_type: file.content_type,
        file_name: file.original_filename,
        file_size: file.size,
      )

      log_documents_uploaded(file.original_filename, uploaded_document.id)
    end
  end

  def upload_evaluation_document_files(files:, evaluator:, evaluation_submitted:)
    return if files.blank?

    files.each do |file|
      uploaded_document = evaluators_upload_documents.create!(
        attachable: Support::Document.create!(case: self, file_type: file.content_type, file:),
        file_type: file.content_type,
        file_name: file.original_filename,
        file_size: file.size,
        email: evaluator.email,
        evaluation_submitted:,
      )

      log_completed_documents_uploaded(file.original_filename, uploaded_document.id, evaluator)
    end
  end

  def upload_contract_handover_files(files:)
    return if files.blank?

    files.each do |file|
      uploaded_document = upload_contract_handovers.create!(
        attachable: Support::Document.create!(case: self, file_type: file.content_type, file:),
        file_type: file.content_type,
        file_name: file.original_filename,
        file_size: file.size,
      )

      log_upload_contract_handover_files(file.original_filename, uploaded_document.id)
    end
  end

  def log_documents_uploaded(file_name, document_id)
    data = { file_name:, document_id:, support_case_id: id, name: "#{Current.agent.first_name} #{Current.agent.last_name}", user_id: Current.agent.id }
    Support::EvaluationJourneyTracking.new(:documents_uploaded, data).call
  end

  def log_completed_documents_uploaded(file_name, document_id, evaluator)
    data = { file_name:, document_id:, support_case_id: id, name: "evaluator #{evaluator.first_name} #{evaluator.last_name}", user_id: evaluator.id }
    Support::EvaluationJourneyTracking.new(:completed_documents_uploaded, data).call
  end

  def log_upload_contract_handover_files(file_name, document_id)
    data = { file_name:, document_id:, support_case_id: id, name: "#{Current.agent.first_name} #{Current.agent.last_name}", user_id: Current.agent.id }
    Support::EvaluationJourneyTracking.new(:handover_packs_uploaded, data).call
  end
end
