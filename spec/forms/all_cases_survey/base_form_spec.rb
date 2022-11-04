describe AllCasesSurvey::BaseForm, type: :model do
  subject(:form) { described_class.new(**data) }

  let(:data) { {} }

  it { is_expected.to delegate_method(:complete_survey!).to(:all_cases_survey_response) }
  it { is_expected.to delegate_method(:case_state).to(:all_cases_survey_response) }
  it { is_expected.to delegate_method(:case_ref).to(:all_cases_survey_response) }
  it { is_expected.to delegate_method(:previous_satisfaction_response).to(:all_cases_survey_response) }

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

  describe "#start_survey!" do
    let(:all_cases_survey_response) { create(:all_cases_survey_response) }
    let(:data) { { id: all_cases_survey_response.id } }

    it "sets the user ip" do
      form.start_survey!("127.0.0.1")
      expect(form.all_cases_survey_response.user_ip).to eq "127.0.0.1"
    end

    it "delegates to the ActiveRecord model" do
      expect(form.all_cases_survey_response).to receive(:start_survey!)
      form.start_survey!("")
    end
  end
end
