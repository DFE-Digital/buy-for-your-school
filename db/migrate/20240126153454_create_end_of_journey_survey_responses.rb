class CreateEndOfJourneySurveyResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :end_of_journey_survey_responses, id: :uuid do |t|
      t.integer :easy_to_use_rating
      t.text :improvements
      t.integer :service

      t.timestamps
    end
  end
end
