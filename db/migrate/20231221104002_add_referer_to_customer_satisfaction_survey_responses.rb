class AddRefererToCustomerSatisfactionSurveyResponses < ActiveRecord::Migration[7.1]
  def change
    add_column :customer_satisfaction_survey_responses, :referer, :string
  end
end
