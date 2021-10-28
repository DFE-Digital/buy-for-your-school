class ChangeSupportDocumentRelationship < ActiveRecord::Migration[6.1]
  def up
    change_table :support_documents, bulk: true do |t|
      t.remove :documentable_type, :documentable_id

      t.column :case_id, :uuid
      t.index :case_id
    end
  end

  def down
    change_table :support_documents, bulk: true do |t|
      t.string :documentable_type
      t.uuid :documentable_id
      t.remove :case_id
      t.index :documentable_type
      t.index :documentable_id
    end
  end
end
