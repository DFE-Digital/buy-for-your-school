class CreateAllCasesSurveyResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :all_cases_survey_responses, id: :uuid do |t|
      t.references :case, foreign_key: { to_table: :support_cases }, type: :uuid
      t.integer :satisfaction_level
      t.text :satisfaction_text
      t.integer :outcome_achieved
      t.text :about_outcomes_text
      t.text :improve_text
      t.integer :status
      t.string :user_ip
      t.datetime :survey_started_at

      t.timestamps
    end
  end
end
