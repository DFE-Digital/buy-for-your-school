require "rails_helper"

RSpec.describe "UsabilitySurveys", type: :request do
  let(:example_url) { "https://example.com" }
  let(:signed_url) { UrlVerifier.verifier.generate(example_url) }

  before do
    allow(UrlVerifier).to receive(:verify_url) { |url| url == signed_url ? example_url : nil }
  end

  describe "POST /usability_surveys" do
    it "redirects to decoded return_url when valid and persists the record" do
      post usability_surveys_path, params: {
        return_url: signed_url,
        usability_survey: {
          service: "find_a_buying_solution",
          usage_reasons: %w[browsing],
          service_helpful: true,
          improvements: "Make it better",
        },
      }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(example_url)
      record = UsabilitySurveyResponse.last
      expect(record.usage_reasons).to include("browsing")
      expect(record.service_helpful).to be true
      expect(record.improvements).to eq("Make it better")
      expect(record.service).to eq("find_a_buying_solution")
    end

    it "redirects to root when return_url invalid" do
      post usability_surveys_path, params: {
        return_url: "invalid_url",
        usability_survey: {
          service: "find_a_buying_solution",
          usage_reasons: %w[browsing],
          service_helpful: true,
          improvements: "Make it better",
        },
      }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
      record = UsabilitySurveyResponse.last
      expect(record.usage_reasons).to include("browsing")
      expect(record.service_helpful).to be true
      expect(record.improvements).to eq("Make it better")
      expect(record.service).to eq("find_a_buying_solution")
    end
  end
end
