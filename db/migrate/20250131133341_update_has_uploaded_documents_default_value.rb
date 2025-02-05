class UpdateHasUploadedDocumentsDefaultValue < ActiveRecord::Migration[7.2]
  def change
    change_column_default :support_evaluators, :has_uploaded_documents, from: nil, to: false
    change_column_default :support_cases, :has_uploaded_documents, from: nil, to: false
  end
end
