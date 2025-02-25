class AddSupportUploadContractHandovers < ActiveRecord::Migration[7.2]
  def change
    create_table "support_upload_contract_handovers", id: :uuid do |t|
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
