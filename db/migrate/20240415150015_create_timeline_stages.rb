class CreateTimelineStages < ActiveRecord::Migration[7.1]
  def change
    create_table :support_timeline_stages, id: :uuid do |t|
      t.integer :stage
      t.string :title
      t.text :description
      t.datetime :complete_by
      t.datetime :started_at
      t.datetime :completed_at
      t.references :support_timeline, foreign_key: { to_table: :support_timelines }, type: :uuid
      t.uuid :approved_version_id
      t.timestamps
    end
  end
end
