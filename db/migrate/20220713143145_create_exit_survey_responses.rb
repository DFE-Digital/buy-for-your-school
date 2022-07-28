class CreateExitSurveyResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :exit_survey_responses, id: :uuid do |t|
      t.references :case, foreign_key: { to_table: :support_cases }, type: :uuid
      t.integer :satisfaction_level
      t.string :satisfaction_text
      t.integer :saved_time
      t.integer :better_quality
      t.integer :future_support
      t.integer :hear_about_service
      t.boolean :opt_in
      t.string :opt_in_name
      t.string :opt_in_email

      t.timestamps
    end
  end
end
