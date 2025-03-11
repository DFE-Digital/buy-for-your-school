class AddSupportDownloadContractHandovers < ActiveRecord::Migration[7.2]
  def change
    create_table "support_download_contract_handovers", id: :uuid do |t|
      t.references "support_case", type: :uuid
      t.references "support_upload_contract_handover", type: :uuid
      t.string "email", null: false
      t.boolean "has_downloaded_documents", default: false
      t.timestamps
      t.index %w[email support_case_id support_upload_contract_handover_id], unique: true
    end
  end
end
