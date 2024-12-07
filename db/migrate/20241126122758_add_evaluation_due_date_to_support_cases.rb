class AddEvaluationDueDateToSupportCases < ActiveRecord::Migration[7.2]
  def change
    add_column :support_cases, :evaluation_due_date, :date
  end
end
