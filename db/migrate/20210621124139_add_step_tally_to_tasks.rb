# Record counters on the task in an extensible manner
class AddStepTallyToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :step_tally, :jsonb
  end
end
