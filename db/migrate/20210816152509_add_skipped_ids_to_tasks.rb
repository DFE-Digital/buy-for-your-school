# Record questions that have been skipped
class AddSkippedIdsToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :skipped_ids, :text, array: true, null: false, default: []
    add_index :tasks, :skipped_ids
  end
end
