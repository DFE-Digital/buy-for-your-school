class CreateFrameworksActivityEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :frameworks_activity_events, id: :uuid do |t|
      t.string :event
      t.jsonb :data

      t.timestamps
    end
  end
end
