class AddSentEmailToEvaluatorsToCase < ActiveRecord::Migration[7.2]
  def change
    add_column :support_cases, :sent_email_to_evaluators, :boolean, default: false
  end
end
