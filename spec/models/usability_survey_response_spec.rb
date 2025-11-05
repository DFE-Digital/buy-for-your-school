require "rails_helper"

describe UsabilitySurveyResponse do
  subject(:survey_response) { described_class.new }

  describe "Validations" do
    it "is not valid without service" do
      survey_response.usage_reasons = %w[browsing]
      survey_response.service_helpful = true
      expect(survey_response).not_to be_valid
      expect(survey_response.errors[:service]).to include("Select which service you used")
    end

    it "requires usage_reason_other if 'other' is checked" do
      survey_response.usage_reasons = %w[other]
      survey_response.service_helpful = true
      survey_response.service = "find_a_buying_solution"
      expect(survey_response).not_to be_valid
      expect(survey_response.errors[:usage_reason_other]).to include("Tell us what you used the service for")
    end

    it "is valid with all required fields" do
      survey_response.usage_reasons = %w[browsing]
      survey_response.service_helpful = false
      survey_response.service_not_helpful_reason = "It was confusing"
      survey_response.service = "find_a_buying_solution"
      expect(survey_response).to be_valid
    end

    it "is invalid with an invalid service value" do
      expect {
        survey_response.service = "invalid_service"
      }.to raise_error(ArgumentError)
    end

    it "accepts all valid usage reasons" do
      I18n.t("usability_survey.usage_reasons.options").each_key do |reason|
        survey_response.usage_reasons = [reason.to_s]
        survey_response.service_helpful = true
        survey_response.service = "find_a_buying_solution"
        if reason.to_s == "other"
          survey_response.usage_reason_other = "Other reason"
        end
        expect(survey_response).to be_valid
      end
    end

    it "is valid if at least one non-service field is present (usage_reasons)" do
      survey_response.service = "find_a_buying_solution"
      survey_response.usage_reasons = %w[browsing]
      expect(survey_response).to be_valid
    end

    it "is valid if at least one non-service field is present (service_helpful)" do
      survey_response.service = "find_a_buying_solution"
      survey_response.service_helpful = true
      expect(survey_response).to be_valid
    end

    it "is not valid if all fields except service are blank" do
      survey_response.service = "find_a_buying_solution"
      expect(survey_response).not_to be_valid
      expect(survey_response.errors[:base]).to include("At least one field must be filled in")
    end

    it "is valid if service_helpful is false and service_not_helpful_reason is present" do
      survey_response.service = "find_a_buying_solution"
      survey_response.service_helpful = false
      survey_response.service_not_helpful_reason = "It was confusing"
      survey_response.usage_reasons = %w[browsing]
      expect(survey_response).to be_valid
    end

    it "sanitizes usage_reasons to remove blanks" do
      survey_response.service = "find_a_buying_solution"
      survey_response.usage_reasons = ["", "browsing", ""]
      survey_response.service_helpful = true
      survey_response.valid?
      expect(survey_response.usage_reasons).to eq(%w[browsing])
    end

    it "requires service_not_helpful_reason when service_helpful is false" do
      survey_response.usage_reasons = %w[browsing]
      survey_response.service_helpful = false
      survey_response.service = "find_a_buying_solution"
      expect(survey_response).not_to be_valid
      expect(survey_response.errors[:service_not_helpful_reason]).to include("Tell us why the service was not helpful")
    end
  end
end
