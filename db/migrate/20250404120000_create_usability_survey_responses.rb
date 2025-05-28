class CreateUsabilitySurveyResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :usability_survey_responses, id: :uuid do |t|
      t.string :usage_reasons, array: true, default: []
      t.text :usage_reason_other
      t.boolean :service_helpful
      t.text :service_not_helpful_reason
      t.text :improvements
      t.integer :service
      t.timestamps
    end
  end
end
