class CreateCustomerSatisfactionSurveyResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :customer_satisfaction_survey_responses, id: :uuid do |t|
      t.integer :satisfaction_level
      t.text :satisfaction_text
      t.integer :easy_to_use_rating
      t.string :helped_how, array: true, default: []
      t.text :helped_how_other
      t.integer :clear_to_use_rating
      t.integer :recommendation_likelihood
      t.text :improvements
      t.boolean :research_opt_in
      t.string :research_opt_in_email
      t.string :research_opt_in_job_title
      t.integer :service
      t.integer :source
      t.integer :status
      t.datetime :survey_sent_at
      t.datetime :survey_started_at
      t.datetime :survey_completed_at

      t.timestamps
    end
  end
end
