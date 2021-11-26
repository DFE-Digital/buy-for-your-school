class CreateSupportActivityLogItem < ActiveRecord::Migration[6.1]
  def change
    create_table :support_activity_log_items, id: :uuid do |t|
      t.string :support_case_id
      t.string :action
      t.jsonb :data

      t.timestamps
    end
  end
end
