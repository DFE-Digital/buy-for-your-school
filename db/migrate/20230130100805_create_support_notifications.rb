class CreateSupportNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :support_notifications, id: :uuid do |t|
      t.integer :topic, default: 0
      t.text :body
      t.references :support_case, null: true, foreign_key: { to_table: :support_cases }, type: :uuid

      t.timestamps
    end
  end
end
