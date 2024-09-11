class AddIsEvaluatorToCase < ActiveRecord::Migration[7.1]
  def change
    add_column :support_cases, :is_evaluator, :boolean, default: false
  end
end
