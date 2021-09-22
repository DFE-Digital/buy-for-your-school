class CreateSupportInteractions < ActiveRecord::Migration[6.1]
  def change
    create_table :support_interactions, id: :uuid do |t|
      t.uuid :agent_id
      t.uuid :case_id
      t.integer :event_type
      t.text :body
      t.timestamps
      t.index :agent_id
      t.index :case_id
      t.index :event_type
    end
  end
end
