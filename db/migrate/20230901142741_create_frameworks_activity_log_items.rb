class CreateFrameworksActivityLogItems < ActiveRecord::Migration[7.0]
  def change
    create_table :frameworks_activity_log_items, id: :uuid do |t|
      t.uuid :actor_id
      t.string :actor_type
      t.uuid :activity_id
      t.string :activity_type
      t.uuid :subject_id
      t.string :subject_type
      t.string :guid

      t.timestamps
    end
  end
end
