class AddEvaluationApprovedToSupportEvaluators < ActiveRecord::Migration[7.2]
  def change
    add_column :support_evaluators, :evaluation_approved, :boolean, default: false
  end
end
