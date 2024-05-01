class CreateTimelines < ActiveRecord::Migration[7.1]
  def change
    create_table :timelines, id: :uuid do |t|
      t.integer :state
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :started_at
      t.datetime :completed_at
      t.references :support_case, foreign_key: { to_table: :support_cases }, type: :uuid
      t.uuid :published_version_id
      t.timestamps
    end
  end
end
