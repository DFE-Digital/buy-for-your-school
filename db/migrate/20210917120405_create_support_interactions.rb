class CreateSupportInteractions < ActiveRecord::Migration[6.1]
  def change
    create_table :support_interactions, id: :uuid do |t|
      t.uuid :agent_id
      t.integer :type
      t.text :body
      t.timestamps
      t.index :agent_id
      t.index :type
    end
  end
end
