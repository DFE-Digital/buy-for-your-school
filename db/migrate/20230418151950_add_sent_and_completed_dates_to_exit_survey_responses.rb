class AddSentAndCompletedDatesToExitSurveyResponses < ActiveRecord::Migration[7.0]
  def change
    change_table :exit_survey_responses, bulk: true do |t|
      t.column :survey_sent_at, :datetime
      t.column :survey_completed_at, :datetime
    end
  end
end
