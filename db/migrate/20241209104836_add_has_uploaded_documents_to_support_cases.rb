class AddHasUploadedDocumentsToSupportCases < ActiveRecord::Migration[7.2]
  def change
    add_column :support_cases, :has_uploaded_documents, :boolean
  end
end
