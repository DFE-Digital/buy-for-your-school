class AddEvaluationSubmittedToSupportEvaluatorsUploadDocuments < ActiveRecord::Migration[7.2]
  def change
    add_column :support_evaluators_upload_documents, :evaluation_submitted, :boolean, default: true
  end
end
