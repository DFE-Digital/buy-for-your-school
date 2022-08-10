class AddStatusToExitSurveys < ActiveRecord::Migration[7.0]
  def change
    change_table :exit_survey_responses, bulk: true do |t|
      t.integer :status
      t.string :user_ip
    end
  end
end
