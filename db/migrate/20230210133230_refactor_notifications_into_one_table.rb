class RefactorNotificationsIntoOneTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :support_notifications, if_exists: true, force: :cascade do |t|
      t.integer :topic, default: 0
      t.text :body
      t.references :support_case, null: true, foreign_key: { to_table: :support_cases }, type: :uuid

      t.timestamps
    end
    rename_table :support_notification_assignments, :support_notifications
    remove_column :support_notifications, :support_notification_id, :uuid
    add_column :support_notifications, :support_case_id, :uuid
    add_foreign_key :support_notifications, :support_cases
    add_column :support_notifications, :topic, :integer
  end
end
