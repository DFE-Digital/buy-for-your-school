class CreateSupportDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :support_documents, id: :uuid do |t|
      t.string :file_type
      t.string :document_body
      t.string :documentable_type, null: false
      t.uuid :documentable_id, null: false
      t.timestamps

      t.index :documentable_type
      t.index :documentable_id
    end
  end
end
