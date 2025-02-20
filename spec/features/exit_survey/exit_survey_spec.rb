RSpec.feature "Completing the Exit Survey" do
  let(:exit_survey) { create(:exit_survey_response) }

  describe "start page" do
    before do
      visit "exit_survey/start/#{exit_survey.id}"
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
    before do
      visit "exit_survey/satisfaction/#{exit_survey.id}/edit"
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

  describe "satisfaciton reason page" do
    before do
      visit "exit_survey/satisfaction_reason/#{exit_survey.id}/edit"
    end

    it "asks why you felt that way about the service" do
      expect(page).to have_text "Tell us why you felt satisfied with the service?"
    end

    it "links back to the satisfaction page" do
      click_on "Back"
      expect(page).to have_text "How do you feel about the service you received?"
    end

    it "continues to the saved time page" do
      fill_in "Tell us why you felt satisfied with the service?", with: "reasons"
      click_continue
      expect(page).to have_text "Do you agree or disagree that using the service saved you or your school time?"
    end
  end

  describe "saved time page" do
    before do
      visit "exit_survey/saved_time/#{exit_survey.id}/edit"
    end

    it "asks if the service saved you time" do
      expect(page).to have_text "Do you agree or disagree that using the service saved you or your school time?"
    end

    it "links back to the satisfaction reason page" do
      click_on "Back"
      expect(page).to have_text "Tell us why you felt satisfied with the service?"
    end

    it "continues to the better quality page" do
      choose "Neither agree nor disagree"
      click_continue
      expect(page).to have_text "Do you agree or disagree that using the service helped your school to buy better quality goods or services?"
    end
  end

  describe "better quality page" do
    before do
      visit "exit_survey/better_quality/#{exit_survey.id}/edit"
    end

    it "asks if the service helped buy better quality goods" do
      expect(page).to have_text "Do you agree or disagree that using the service helped your school to buy better quality goods or services?"
    end

    it "links back to the saved time page" do
      click_on "Back"
      expect(page).to have_text "Do you agree or disagree that using the service saved you or your school time?"
    end

    it "continues to the future support page" do
      choose "Disagree"
      click_continue
      expect(page).to have_text "Do you agree or disagree that you've learned enough to run the same type of procurement in the future with less support?"
    end
  end

  describe "future support page" do
    before do
      visit "exit_survey/future_support/#{exit_survey.id}/edit"
    end

    it "asks if you may run a procurement without support in future" do
      expect(page).to have_text "Do you agree or disagree that you've learned enough to run the same type of procurement in the future with less support?"
    end

    it "links back to the better quality page" do
      click_on "Back"
      expect(page).to have_text "Do you agree or disagree that using the service helped your school to buy better quality goods or services?"
    end

    it "continues to the hear about service page" do
      choose "Strongly agree"
      click_continue
      expect(page).to have_text "How did you hear about the service?"
    end
  end

  describe "hear about service page" do
    before do
      visit "exit_survey/hear_about_service/#{exit_survey.id}/edit"
    end

    it "asks how you heard about the service" do
      expect(page).to have_text "How did you hear about the service?"
    end

    it "links back to the future support page" do
      click_on "Back"
      expect(page).to have_text "Do you agree or disagree that you've learned enough to run the same type of procurement in the future with less support?"
    end

    it "continues to the opt in page" do
      choose "Other"
      fill_in "Please specify", with: "Elsewhere"
      click_continue
      expect(page).to have_text "Would you like to be contacted about DfE research opportunities?"
    end
  end

  describe "opt in page" do
    before do
      visit "exit_survey/opt_in/#{exit_survey.id}/edit"
    end

    it "asks if you would like to participate in UR" do
      expect(page).to have_text "Would you like to be contacted about DfE research opportunities?"
    end

    it "links back to the hear about service page" do
      click_on "Back"
      expect(page).to have_text "How did you hear about the service?"
    end

    it "continues to the opt in detail page" do
      choose "Yes"
      click_continue
      expect(page).to have_text "Provide your details to opt in to research opportunities"
    end
  end

  describe "opt in detail page" do
    before do
      visit "exit_survey/opt_in_detail/#{exit_survey.id}/edit"
    end

    it "asks for your details" do
      expect(page).to have_text "Provide your details to opt in to research opportunities"
    end

    it "links back to the opt in page" do
      click_on "Back"
      expect(page).to have_text "Would you like to be contacted about DfE research opportunities?"
    end

    it "continues to the thank you page" do
      fill_in "Full name", with: "name"
      fill_in "Email address", with: "name@email.com"
      click_continue
      expect(page).to have_text "Thank you"
    end
  end

  describe "thank you page" do
    before do
      visit "exit_survey/thank_you/#{exit_survey.id}"
    end

    it "thanks for completing the form" do
      expect(page).to have_text "Thank you"
    end

    it "links to GHBS guidance" do
      expect(page).to have_link "Get help buying for schools", href: "https://www.gov.uk/guidance/get-help-buying-for-schools"
    end
  end
end
