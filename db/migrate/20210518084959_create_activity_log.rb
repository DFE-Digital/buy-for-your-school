class CreateActivityLog < ActiveRecord::Migration[6.1]
  def change
    create_table :activity_log, id: :uuid do |t|
      t.string :journey_id
      t.string :user_id
      t.string :contentful_category_id
      t.string :contentful_section_id
      t.string :contentful_task_id
      t.string :contentful_step_id
      t.string :action
      t.jsonb :data
      t.timestamps
      t.index :journey_id
      t.index :user_id
      t.index :contentful_category_id
      t.index :contentful_section_id
      t.index :contentful_task_id
      t.index :contentful_step_id
      t.index :action
    end
  end
end
