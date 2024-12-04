class AddIsUploadDocumentsToSupportCases < ActiveRecord::Migration[7.2]
  def change
    add_column :support_cases, :is_upload_documents, :boolean
  end
end
