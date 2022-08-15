class AddOtherTextToExitSurveyResponses < ActiveRecord::Migration[6.1]
  def change
    add_column :exit_survey_responses, :hear_about_service_other, :string
  end
end
