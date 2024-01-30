require "rails_helper"

describe "Filling out an end-of-journey survey for a specific service" do
  let(:service) { nil }
  let(:params) { { end_of_journey_survey: { easy_to_use_rating: "agree", service: } } }

  context "when the service is Find a Framework" do
    let(:params) { { easy_to_use_rating: "agree", improvements: "do better", service: "find_a_framework" } }

    context "when the request is unauthenticated" do
      let(:headers) { { "Content-Type" => "application/json", "Accept" => "application/json" } }

      before { post end_of_journey_surveys_path, params:, headers:, as: :json }

      it "returns unauthorized and does not save the feedback" do
        expect(response).to have_http_status(:unauthorized)
        expect(EndOfJourneySurveyResponse.count).to be_zero
      end
    end

    context "when the request is authenticated" do
      let(:auth_token) { ActionController::HttpAuthentication::Token.encode_credentials("test") }
      let(:headers) { { "Content-Type" => "application/json", "Accept" => "application/json", "Authorization" => auth_token } }

      before { post end_of_journey_surveys_path, params:, headers:, as: :json }

      it "saves Find a Framework feedback" do
        expect(response).to have_http_status(:ok)
        expect(EndOfJourneySurveyResponse.first.easy_to_use_rating).to eq("agree")
        expect(EndOfJourneySurveyResponse.first.improvements).to eq("do better")
        expect(EndOfJourneySurveyResponse.first.service).to eq("find_a_framework")
      end
    end
  end

  context "when the service is the Request For Help form" do
    let(:service) { "request_for_help_form" }

    before { post end_of_journey_surveys_path, params: }

    it "saves Request For Help as the service" do
      expect(EndOfJourneySurveyResponse.first.service).to eq("request_for_help_form")
    end
  end
end
