RSpec.feature "Completing the All Cases Survey" do
  let(:all_cases_survey) { create(:all_cases_survey_response, case:) }
  let(:case) { create(:support_case, state:) }
  let(:state) { "resolved" }

  describe "start page" do
    before do
      visit "all_cases_survey/start/#{all_cases_survey.id}"
    end

    it "begins on the start page" do
      expect(page).to have_text "Get help buying for schools feedback"
    end

    it "links to the privacy policy" do
      expect(page).to have_link "Privacy policy", href: "/privacy"
    end

    it "continues to the statisfaction page" do
      click_continue
      expect(page).to have_text "How do you feel about the service you received?"
    end
  end

  describe "satisfaciton page" do
    context "when the satisfaction_level param is provided" do
      let(:param) { "very_satisfied" }

      before do
        visit "all_cases_survey/satisfaction/#{all_cases_survey.id}/edit?satisfaction_level=#{param}"
      end

      it "persists the satisfaction_level value" do
        expect(AllCasesSurveyResponse.first.satisfaction_level).to eq "very_satisfied"
      end

      it "redirects to the satisfaction reason page" do
        expect(page).to have_text "Tell us why you felt very satisfied with the service?"
      end
    end

    context "when accessed directly" do
      before do
        visit "all_cases_survey/satisfaction/#{all_cases_survey.id}/edit"
      end

      it "asks how you feel about the service" do
        expect(page).to have_text "How do you feel about the service you received?"
      end

      it "links back to the start page" do
        click_on "Back"
        expect(page).to have_text "Get help buying for schools feedback"
      end

      it "continues to the statisfaction reason page" do
        choose "Satisfied"
        click_continue
        expect(page).to have_text "Tell us why you felt satisfied with the service?"
      end
    end
  end

  describe "satisfaciton reason page" do
    before do
      visit "all_cases_survey/satisfaction_reason/#{all_cases_survey.id}/edit"
    end

    it "asks why you felt that way about the service" do
      expect(page).to have_text "Tell us why you felt satisfied with the service?"
    end

    it "links back to the satisfaction page" do
      click_on "Back"
      expect(page).to have_text "How do you feel about the service you received?"
    end

    context "when the linked case is resolved" do
      let(:state) { "resolved" }

      it "continues to the outcome achieved page" do
        fill_in "Tell us why you felt satisfied with the service?", with: "reasons"
        click_continue
        expect(page).to have_text "I achieved the outcome I wanted as a result of the support I received from Get help buying for schools"
      end
    end

    context "when the linked case is open" do
      let(:state) { "opened" }

      it "continues to the improvements page" do
        fill_in "Tell us why you feel satisfied with the service so far?", with: "reasons"
        click_continue
        expect(page).to have_text "Please tell us how we can improve this service?"
      end
    end
  end

  describe "outcome achieved page" do
    before do
      visit "all_cases_survey/outcome_achieved/#{all_cases_survey.id}/edit"
    end

    it "asks if the outcome they wanted was achieved" do
      expect(page).to have_text "I achieved the outcome I wanted as a result of the support I received from Get help buying for schools"
    end

    it "links back to the satisfaction reason page" do
      click_on "Back"
      expect(page).to have_text "Tell us why you felt satisfied with the service?"
    end

    it "continues to the about outcome page" do
      choose "Neither agree nor disagree"
      click_continue
      expect(page).to have_text "Tell us about the outcomes you were able to achieve because of the support you received"
    end
  end

  describe "about outcomes page" do
    before do
      visit "all_cases_survey/about_outcomes/#{all_cases_survey.id}/edit"
    end

    it "asks to tell more about the outcomes achieved" do
      expect(page).to have_text "Tell us about the outcomes you were able to achieve because of the support you received"
    end

    it "links back to the outcome achieved page" do
      click_on "Back"
      expect(page).to have_text "I achieved the outcome I wanted as a result of the support I received from Get help buying for schools"
    end

    it "continues to the improvement page" do
      fill_in "Tell us about the outcomes you were able to achieve because of the support you received", with: "outcomes"
      click_continue
      expect(page).to have_text "Please tell us how we can improve this service?"
    end
  end

  describe "improvements page" do
    before do
      visit "all_cases_survey/improvements/#{all_cases_survey.id}/edit"
    end

    it "asks for improvements" do
      expect(page).to have_text "Please tell us how we can improve this service?"
    end

    it "continues to the accessibility research page" do
      fill_in "Please tell us how we can improve this service?", with: "improvements"
      click_continue
      expect(page).to have_text "Would you like to take part in a research session to help us improve our service for disabled users and users with accessibility needs?"
    end

    context "when the linked case is resolved" do
      let(:state) { "resolved" }

      it "links back to the about outcomes page" do
        click_on "Back"
        expect(page).to have_text "Tell us about the outcomes you were able to achieve because of the support you received"
      end
    end

    context "when the linked case is open" do
      let(:state) { "opened" }

      it "links back to the satisfaction reason page" do
        click_on "Back"
        expect(page).to have_text "Tell us why you feel satisfied with the service so far?"
      end
    end
  end

  describe "accessibility research page" do
    before do
      visit "all_cases_survey/accessibility_research/#{all_cases_survey.id}/edit"
    end

    it "asks to partiticpate in accessibility UR" do
      expect(page).to have_text "Would you like to take part in a research session to help us improve our service for disabled users and users with accessibility needs?"
    end

    it "links back to the improvements page" do
      click_on "Back"
      expect(page).to have_text "Please tell us how we can improve this service?"
    end

    it "continues to the thank you page" do
      choose "Yes"
      click_continue
      expect(page).to have_text "Thank you"
    end
  end

  describe "thank you page" do
    before do
      visit "all_cases_survey/thank_you/#{all_cases_survey.id}"
    end

    it "thanks for completing the form" do
      expect(page).to have_text "Thank you"
    end

    it "links to GHBS guidance" do
      expect(page).to have_link "Get help buying for schools", href: "https://www.gov.uk/guidance/get-help-buying-for-schools"
    end
  end
end
