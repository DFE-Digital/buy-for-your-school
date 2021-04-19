class AddTaskAssociationToSteps < ActiveRecord::Migration[6.1]
  def change
    add_column :steps, :task_id, :uuid
    add_index :steps, :task_id
    remove_column :steps, :journey_id, :uuid
  end
end
