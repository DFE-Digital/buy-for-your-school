class CreateTimelineDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :timeline_documents, id: :uuid do |t|
      t.string :name
      t.string :ms_graph_drive_item_id
      t.string :url
      t.integer :permissions
      t.string :last_modified_by
      t.datetime :last_modified_at
      t.references :timeline_task, foreign_key: { to_table: :timeline_tasks }, type: :uuid
      t.timestamps
    end
  end
end
