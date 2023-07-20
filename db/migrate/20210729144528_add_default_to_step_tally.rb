class AddDefaultToStepTally < ActiveRecord::Migration[6.1]
  def change
    change_column_default :tasks, :step_tally, from: nil, to: "{}"

    # NB: ensure tasks created before the addition of the step_tally are populated
    Task.where(step_tally: nil).map(&:save).count
  end
end
