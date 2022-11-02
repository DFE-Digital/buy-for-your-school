class AddAccessibilityResearchToAllCasesSurveyResponses < ActiveRecord::Migration[7.0]
  def change
    add_column :all_cases_survey_responses, :accessibility_research_opt_in, :boolean
  end
end
