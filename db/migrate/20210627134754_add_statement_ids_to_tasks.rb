class AddStatementIdsToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :statement_ids, :text, array: true, null: false, default: []
    add_index :tasks, :statement_ids
  end
end
