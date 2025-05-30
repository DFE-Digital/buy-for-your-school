class AddSupportCaseUploadDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table "support_case_upload_documents", id: :uuid do |t|
      t.references "support_case", type: :uuid
      t.string "file_type"
      t.string "file_name"
      t.bigint "file_size"
      t.uuid "attachable_id"
      t.string "attachable_type"
      t.timestamps
    end
  end
end
