require "rails_helper"

RSpec.feature "Completing the Usability Survey" do
  let(:example_url) { "/__dummy_return__" }
  let(:test_improvement) { "Make it better" }
  let(:signed_url) { UrlVerifier.verifier.generate(example_url) }

  def submit_form
    click_button I18n.t("usability_survey.send")
  end

  before do
    allow(UrlVerifier).to receive(:verify_url) do |url|
      url == signed_url ? example_url : nil
    end
  end

  describe "new page" do
    before do
      visit new_usability_survey_path(return_url: signed_url, service: "find_a_buying_solution")
    end

    it "shows the survey form" do
      expect(page).to have_text I18n.t("usability_survey.heading")
      expect(page).to have_text I18n.t("usability_survey.body")
    end

    it "has a skip survey link" do
      expect(page).to have_link "Skip survey", href: example_url
    end

    context "when selecting 'other' usage reason" do
      it "shows the other reason text area" do
        check I18n.t("usability_survey.usage_reasons.options.other")
        expect(page).to have_field I18n.t("usability_survey.usage_reasons.usage_reason_other")
      end
    end

    context "when selecting service not helpful" do
      it "shows the reason text area" do
        choose I18n.t("generic.no", default: "No")
        expect(page).to have_field I18n.t("usability_survey.service_not_helpful_reason")
      end
    end

    context "when submitting without filling required fields" do
      it "shows validation errors" do
        submit_form
        expect(page).to have_text "At least one field must be filled in"
      end
    end

    context "when submitting with valid data" do
      it "saves the survey when submitting valid data" do
        check I18n.t("usability_survey.usage_reasons.options.browsing")
        choose I18n.t("generic.yes", default: "Yes")
        fill_in I18n.t("usability_survey.improvements"), with: test_improvement
        submit_form

        expect(UsabilitySurveyResponse.last.usage_reasons).to include("browsing")
        expect(UsabilitySurveyResponse.last.service_helpful).to be true
        expect(UsabilitySurveyResponse.last.improvements).to eq(test_improvement)
        expect(UsabilitySurveyResponse.last.service).to eq("find_a_buying_solution")
      end
    end
  end
end
