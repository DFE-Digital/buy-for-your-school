class AddStepTallyToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :step_tally, :jsonb
  end
end
