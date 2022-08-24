class AddSurveyStartedToExitSurveyResponses < ActiveRecord::Migration[7.0]
  def change
    add_column :exit_survey_responses, :survey_started_at, :datetime
  end
end
