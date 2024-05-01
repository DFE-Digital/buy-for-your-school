class CreateTimelineTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :timeline_tasks, id: :uuid do |t|
      t.string :title
      t.text :description
      t.integer :state
      t.integer :status
      t.integer :type
      t.datetime :start_date
      t.datetime :end_date
      t.interval :duration
      t.integer :visibility
      t.datetime :started_at
      t.datetime :completed_at
      t.references :timeline_stage, foreign_key: { to_table: :timeline_stages }, type: :uuid
      t.uuid :published_version_id
      t.timestamps
    end
  end
end
