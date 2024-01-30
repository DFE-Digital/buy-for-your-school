require "rails_helper"

describe EndOfJourneySurveyResponse do
  subject(:survey_response) { described_class.new }

  describe "Validations" do
    it "is not valid without an easy to use rating" do
      expect(survey_response).not_to be_valid(:easy_to_use_rating)
      expect(survey_response.errors.messages[:easy_to_use_rating]).to eq(["Select how strongly you agree that this form was easy to use"])
    end
  end
end
