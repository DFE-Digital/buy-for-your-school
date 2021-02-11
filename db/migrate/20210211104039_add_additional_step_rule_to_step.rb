class AddAdditionalStepRuleToStep < ActiveRecord::Migration[6.1]
  def change
    add_column :steps, :additional_step_rule, :jsonb
  end
end
