class AddActionRequiredToFrameworkEvaluations < ActiveRecord::Migration[7.0]
  def change
    add_column :frameworks_evaluations, :action_required, :boolean, default: false
  end
end
