class AddHasUploadedDocumentsToSupportEvaluators < ActiveRecord::Migration[7.2]
  def change
    add_column :support_evaluators, :has_uploaded_documents, :boolean
  end
end
