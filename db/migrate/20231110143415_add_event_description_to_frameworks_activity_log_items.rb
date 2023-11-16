class AddEventDescriptionToFrameworksActivityLogItems < ActiveRecord::Migration[7.1]
  def change
    add_column :frameworks_activity_log_items, :event_description, :string
  end
end
