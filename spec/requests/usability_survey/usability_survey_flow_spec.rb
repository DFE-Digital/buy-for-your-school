require "rails_helper"

describe "Filling out a usability survey" do
  let(:params) do
    {
      usability_survey: {
        usage_reasons: %w[browsing other],
        usage_reason_other: "Some other reason",
        service_helpful: "false",
        service_not_helpful_reason: "It was confusing",
        improvements: "do better",
        service: "find_a_buying_solution",
      },
    }
  end

  let(:signed_url) { UrlVerifier.verifier.generate("/somewhere") }

  it "creates the survey response and redirects to root" do
    expect { post usability_surveys_path, params: }.to change(UsabilitySurveyResponse, :count).by(1)
    expect(response).to redirect_to(root_path)

    survey = UsabilitySurveyResponse.last
    expect(survey.usage_reasons).to include("browsing", "other")
    expect(survey.usage_reason_other).to eq("Some other reason")
    expect(survey.service_helpful).to eq(false)
    expect(survey.service_not_helpful_reason).to eq("It was confusing")
    expect(survey.improvements).to eq("do better")
    expect(survey.service).to eq("find_a_buying_solution")
  end

  it "creates the survey response and redirects to return_url if provided and verified" do
    expect {
      post usability_surveys_path, params: params.merge(return_url: signed_url)
    }.to change(UsabilitySurveyResponse, :count).by(1)
    expect(response).to redirect_to("/somewhere")
  end

  it "redirects to root if return_url is not verified" do
    allow(UrlVerifier).to receive(:verify_url).with(signed_url).and_return(nil)
    expect {
      post usability_surveys_path, params: params.merge(return_url: signed_url)
    }.to change(UsabilitySurveyResponse, :count).by(1)
    expect(response).to redirect_to(root_path)
  end

  it "shows errors if required fields are missing" do
    post usability_surveys_path, params: { usability_survey: {} }
    expect(response.body).to include("At least one field must be filled in")
  end

  it "shows errors if service is missing" do
    post usability_surveys_path, params: { usability_survey: { usage_reasons: %w[browsing], service_helpful: true } }
    expect(response.body).to include("Select which service you used")
  end

  it "shows errors if usage_reason_other is missing when 'other' is selected" do
    post usability_surveys_path, params: { usability_survey: { usage_reasons: %w[other], service: "find_a_buying_solution", service_helpful: true } }
    expect(response.body).to include("Tell us what you used the service for")
  end

  it "allows improvements to be blank" do
    expect {
      post usability_surveys_path, params: { usability_survey: { usage_reasons: %w[browsing], service: "find_a_buying_solution", service_helpful: true } }
    }.to change(UsabilitySurveyResponse, :count).by(1)
    expect(response).to redirect_to(root_path)
    expect(UsabilitySurveyResponse.last.improvements).to be_nil
  end

  it "removes blank values from usage_reasons on submit" do
    post usability_surveys_path, params: { usability_survey: { usage_reasons: ["", "browsing", ""], service: "find_a_buying_solution", service_helpful: true } }
    expect(UsabilitySurveyResponse.last.usage_reasons).to eq(%w[browsing])
  end

  it "shows errors if service_not_helpful_reason is missing when service_helpful is false" do
    post usability_surveys_path, params: { usability_survey: { usage_reasons: %w[browsing], service: "find_a_buying_solution", service_helpful: false } }
    expect(response.body).to include("Tell us why the service was not helpful")
  end
end
