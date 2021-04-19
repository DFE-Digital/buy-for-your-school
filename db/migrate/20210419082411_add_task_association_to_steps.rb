class AddTaskAssociationToSteps < ActiveRecord::Migration[6.1]
  def change
    add_column :steps, :task_id, :string
    add_index :steps, :task_id
  end
end
