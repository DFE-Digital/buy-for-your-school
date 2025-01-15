class AddSupportEvaluatorsDownloadDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table "support_evaluators_download_documents", id: :uuid do |t|
      t.references "support_case", type: :uuid
      t.references "support_case_upload_document", type: :uuid
      t.string "email", null: false
      t.boolean "has_downloaded_documents", default: false
      t.timestamps
      t.index %w[email support_case_id support_case_upload_document_id], unique: true
    end
  end
end
