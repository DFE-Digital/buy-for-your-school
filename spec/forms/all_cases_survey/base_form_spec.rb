describe AllCasesSurvey::BaseForm, type: :model do
  subject(:form) { described_class.new(**data) }

  describe "#to_h" do
    let(:data) { { id: "id" } }

    it "returns the instance variables and their values" do
      expect(form.to_h).to eq data
    end
  end

  describe "#data" do
    let(:data) { { id: "id" } }

    it "returns the instance variables relevant for persisting" do
      expect(form.data).to eq({})
    end
  end

  describe "#all_cases_survey_response" do
    let(:all_cases_survey_response) { create(:all_cases_survey_response) }
    let(:data) { { id: all_cases_survey_response.id } }

    it "returns the survey response" do
      expect(form.all_cases_survey_response).to eq all_cases_survey_response
      expect(form.all_cases_survey_response).to be_kind_of AllCasesSurveyResponsePresenter
    end
  end

  describe "#show_outcome_questions?" do
    let(:all_cases_survey_response) { create(:all_cases_survey_response) }
    let(:data) { { id: all_cases_survey_response.id } }

    it "delegates to AllCasesSurveyResponsePresenter.case_resolved?" do
      expect(form.all_cases_survey_response).to receive(:case_resolved?)

      form.show_outcome_questions?
    end
  end
end
