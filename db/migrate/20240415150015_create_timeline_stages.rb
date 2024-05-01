class CreateTimelineStages < ActiveRecord::Migration[7.1]
  def change
    create_table :timeline_stages, id: :uuid do |t|
      t.string :title
      t.text :description
      t.integer :stage
      t.integer :state
      t.datetime :complete_by
      t.datetime :started_at
      t.datetime :completed_at
      t.references :timeline, foreign_key: { to_table: :timelines }, type: :uuid
      t.uuid :published_version_id
      t.timestamps
    end
  end
end
