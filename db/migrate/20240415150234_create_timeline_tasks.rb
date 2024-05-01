class CreateTimelineTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :support_timeline_tasks, id: :uuid do |t|
      t.string :title
      t.text :description
      t.integer :status
      t.integer :type
      t.datetime :start_date
      t.datetime :end_date
      t.interval :duration
      t.integer :visibility
      t.datetime :started_at
      t.datetime :completed_at
      t.references :support_timeline_stage, foreign_key: { to_table: :support_timeline_stages }, type: :uuid
      t.uuid :approved_version_id
      t.timestamps
    end
  end
end
