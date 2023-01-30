class CreateSupportNotificationAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :support_notification_assignments, id: :uuid do |t|
      t.references :support_notification, null: false, foreign_key: true, index: { name: "index_support_notification_assigns_on_support_notification_id" }, type: :uuid
      t.references :assigned_by, null: true, foreign_key: { to_table: :support_agents }, type: :uuid
      t.references :assigned_to, null: false, foreign_key: { to_table: :support_agents }, type: :uuid
      t.boolean :assigned_by_system, default: false
      t.boolean :read, default: false
      t.datetime :read_at

      t.timestamps
    end
  end
end
