require "rails_helper"

describe "Answering the satisfaction question" do
  context "when the survey is created for an exit survey email" do
    let(:survey) { create(:customer_satisfaction_survey_response, source: :exit_survey) }

    before do
      visit edit_customer_satisfaction_surveys_satisfaction_level_path(survey)
    end

    it "does not feature a conditional text area to capture satisfaction reason" do
      choose "Very satisfied"
      expect(page).not_to have_content("Please tell us why you gave that score")
    end
  end

  context "when the survey is created via banner link" do
    let(:survey) { create(:customer_satisfaction_survey_response, source: :banner_link) }

    before do
      visit edit_customer_satisfaction_surveys_satisfaction_level_path(survey)
    end

    it "features a conditional text area to capture satisfaction reason" do
      choose "Very satisfied"
      expect(page).to have_content("Please tell us why you gave that score")
    end
  end
end
