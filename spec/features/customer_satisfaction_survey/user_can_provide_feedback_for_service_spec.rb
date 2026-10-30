require "rails_helper"

describe "User can provide feedback for different services" do
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

  context "when in the energy form" do
    let(:energy_start_page) do
      OpenStruct.new(
        title: "Energy for schools",
        description: "Energy for schools description",
        body: "Start page body",
        related_content: [],
        parent: nil,
        slug: "energy/start",
        attachments: [],
        seo_description: nil,
      )
    end

    before do
      allow(FABS::Page).to receive(:find_by_slug!).with("energy/start").and_return(energy_start_page)

      visit energy_start_path

      within(".govuk-phase-banner") do
        click_link "feedback"
      end

      click_button "Continue"
    end

    it "links to a feedback form for Energy from the beta banner link" do
      expect(CustomerSatisfactionSurveyResponse.first.source).to eq("banner_link")
      expect(CustomerSatisfactionSurveyResponse.first.service).to eq("energy_for_schools")
      expect(CustomerSatisfactionSurveyResponse.first.referer).to eq(energy_start_url)
    end
  end
end
