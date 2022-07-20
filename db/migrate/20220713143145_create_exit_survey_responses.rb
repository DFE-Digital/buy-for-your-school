class CreateExitSurveyResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :exit_survey_responses, id: :uuid do |t|
      t.string :case_id, null: false
      t.string :case_ref, null: false
      t.string :satisfaction_level
      t.string :satisfaction_text
      t.string :saved_time
      t.string :better_quality
      t.string :future_support
      t.string :hear_about_service
      t.boolean :opt_in
      t.string :opt_in_name
      t.string :opt_in_email

      t.timestamps
    end
  end
end
