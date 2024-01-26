class AddSupportCaseIdToCustomerSatistfactionSurveyResponses < ActiveRecord::Migration[7.1]
  def change
    add_column :customer_satisfaction_survey_responses, :support_case_id, :uuid
  end
end
