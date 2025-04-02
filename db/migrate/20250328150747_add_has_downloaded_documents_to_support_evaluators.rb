class AddHasDownloadedDocumentsToSupportEvaluators < ActiveRecord::Migration[7.2]
  def change
    add_column :support_evaluators, :has_downloaded_documents, :boolean, default: false
  end
end
