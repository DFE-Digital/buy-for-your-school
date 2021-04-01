class ChangeAdditionalStepRuleName < ActiveRecord::Migration[6.1]
  def change
    rename_column :steps, :additional_step_rule, :additional_step_rules
  end
end
