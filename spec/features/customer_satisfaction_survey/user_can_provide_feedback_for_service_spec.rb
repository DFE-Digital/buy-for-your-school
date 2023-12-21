require "rails_helper"

describe "User can provide feedback for different services" do
  context "when in Create-a-Spec" do
    before do
      user_is_signed_in
      visit dashboard_path

      within(".govuk-phase-banner") do
        click_link "feedback"
      end

      click_button "Continue"
    end

    it "links to a feedback form for Create-a-Spec from the beta banner link" do
      expect(CustomerSatisfactionSurveyResponse.first.source).to eq("banner_link")
      expect(CustomerSatisfactionSurveyResponse.first.service).to eq("create_a_spec")
      expect(CustomerSatisfactionSurveyResponse.first.referer).to eq(dashboard_url)
    end
  end

  context "when in the the Request for Help form" do
    before do
      visit framework_requests_path

      within(".govuk-phase-banner") do
        click_link "feedback"
      end

      click_button "Continue"
    end

    it "links to a feedback form for the Request for Help form from the beta banner link" do
      expect(CustomerSatisfactionSurveyResponse.first.source).to eq("banner_link")
      expect(CustomerSatisfactionSurveyResponse.first.service).to eq("request_for_help_form")
      expect(CustomerSatisfactionSurveyResponse.first.referer).to eq(framework_requests_url)
    end
  end

  context "when in CMS" do
    include_context "with an agent"

    before do
      visit support_cases_path

      within(".govuk-phase-banner") do
        click_link "feedback"
      end

      click_button "Continue"
    end

    it "links to a feedback form for Create-a-Spec from the beta banner link" do
      expect(CustomerSatisfactionSurveyResponse.first.source).to eq("banner_link")
      expect(CustomerSatisfactionSurveyResponse.first.service).to eq("supported_journey")
      expect(CustomerSatisfactionSurveyResponse.first.referer).to eq(support_cases_url)
    end
  end
end
