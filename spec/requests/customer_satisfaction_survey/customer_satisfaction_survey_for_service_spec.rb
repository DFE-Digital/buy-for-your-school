require "rails_helper"

describe "Filling out a customer satisfaction survey for a specific service via a banner link" do
  let(:source) { "banner_link" }
  let(:service) { nil }
  let(:referer) { "previous_url" }
  let(:params) { { service:, source:, referer: } }

  context "when the service is Create-a-Spec" do
    let(:service) { "create_a_spec" }

    before { post customer_satisfaction_surveys_path, params: }

    it "saves Create-a-Spec as the service and and banner link as the source" do
      expect(CustomerSatisfactionSurveyResponse.first.source).to eq("banner_link")
      expect(CustomerSatisfactionSurveyResponse.first.service).to eq("create_a_spec")
      expect(CustomerSatisfactionSurveyResponse.first.referer).to eq("previous_url")
    end
  end

  context "when the service is the Request For Help form" do
    let(:service) { "request_for_help_form" }

    before { post customer_satisfaction_surveys_path, params: }

    it "saves Request For Help as the service and and banner link as the source" do
      expect(CustomerSatisfactionSurveyResponse.first.source).to eq("banner_link")
      expect(CustomerSatisfactionSurveyResponse.first.service).to eq("request_for_help_form")
      expect(CustomerSatisfactionSurveyResponse.first.referer).to eq("previous_url")
    end
  end

  context "when the service is Find a Framework" do
    let(:service) { "find_a_framework" }

    before { post customer_satisfaction_surveys_path, params: }

    it "saves Find a Framework as the service and and banner link as the source" do
      expect(CustomerSatisfactionSurveyResponse.first.source).to eq("banner_link")
      expect(CustomerSatisfactionSurveyResponse.first.service).to eq("find_a_framework")
      expect(CustomerSatisfactionSurveyResponse.first.referer).to eq("previous_url")
    end
  end
end
