class AddEvaluationSubmittedToSupportEvaluators < ActiveRecord::Migration[7.2]
  def change
    add_column :support_evaluators, :evaluation_submitted, :boolean, default: false
  end
end
