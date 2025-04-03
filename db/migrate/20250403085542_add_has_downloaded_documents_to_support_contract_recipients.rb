class AddHasDownloadedDocumentsToSupportContractRecipients < ActiveRecord::Migration[7.2]
  def change
    add_column :support_contract_recipients, :has_downloaded_documents, :boolean, default: false
  end
end
