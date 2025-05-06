require "rails_helper"

RSpec.feature "Completing the Usability Survey" do
  let(:signed_url) { UrlVerifier.verifier.generate("https://example.com") }

  before do
    # Mock URL verification to return the decoded URL for the signed URL
    allow(UrlVerifier).to receive(:verify_url) do |url|
      url == signed_url ? "https://example.com" : nil
    end
  end

  describe "new page" do
    before do
      visit new_usability_survey_path(return_url: signed_url, service: "find_a_buying_solution")
    end

    it "shows the survey form" do
      expect(page).to have_text "Before you go"
      expect(page).to have_text "Please could you let us know how easy it was to use this service"
    end

    it "has a skip survey link" do
      expect(page).to have_link "Skip survey", href: "https://example.com"
    end

    context "when selecting 'other' usage reason" do
      it "shows the other reason text area" do
        check "Other"
        expect(page).to have_field "Label - text area"
      end
    end

    context "when selecting service not helpful" do
      it "shows the reason text area" do
        choose "No"
        expect(page).to have_field "Why not?"
      end
    end

    context "when submitting without filling required fields" do
      it "shows validation errors" do
        click_button "Send feedback"
        expect(page).to have_text "At least one field must be filled in"
      end
    end

    context "when submitting with valid data" do
      it "creates the survey and redirects" do
        check "Browsing"
        choose "Yes"
        fill_in "How could we improve this service?", with: "Make it better"
        click_button "Send feedback"

        expect(UsabilitySurveyResponse.last.usage_reasons).to include("browsing")
        expect(UsabilitySurveyResponse.last.service_helpful).to be true
        expect(UsabilitySurveyResponse.last.improvements).to eq("Make it better")
        expect(UsabilitySurveyResponse.last.service).to eq("find_a_buying_solution")
        expect(page).to have_current_path("https://example.com")
      end
    end
  end

  describe "with invalid return_url" do
    before do
      visit new_usability_survey_path(return_url: "invalid_url", service: "find_a_buying_solution")
    end

    it "redirects to root after submission" do
      check "Browsing"
      choose "Yes"
      fill_in "How could we improve this service?", with: "Make it better"
      click_button "Send feedback"

      expect(UsabilitySurveyResponse.last.usage_reasons).to include("browsing")
      expect(UsabilitySurveyResponse.last.service_helpful).to be true
      expect(UsabilitySurveyResponse.last.improvements).to eq("Make it better")
      expect(UsabilitySurveyResponse.last.service).to eq("find_a_buying_solution")
      expect(page).to have_current_path("/")
    end

    it "has a skip survey link to root" do
      expect(page).to have_link "Skip survey", href: "/"
    end
  end
end
