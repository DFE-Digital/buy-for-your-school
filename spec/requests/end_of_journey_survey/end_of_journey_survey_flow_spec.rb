require "rails_helper"

describe "Filling out an end-of-journey survey" do
  let(:params) { { end_of_journey_survey: { easy_to_use_rating: "agree", improvements: "do better", service: "request_for_help_form" } } }

  it "creates the survey response and redirects to the thank you page" do
    expect { post end_of_journey_surveys_path, params: }.to change(EndOfJourneySurveyResponse, :count).by(1)
    expect(response).to redirect_to(end_of_journey_surveys_thank_you_path)

    survey = EndOfJourneySurveyResponse.last
    expect(survey.easy_to_use_rating).to eq("agree")
    expect(survey.improvements).to eq("do better")
    expect(survey.service).to eq("request_for_help_form")
  end
end
