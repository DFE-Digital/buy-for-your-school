RSpec.describe AllCasesSurveyResponsePresenter do
  subject(:presenter) { described_class.new(all_cases_survey_response) }

  describe "#case_ref" do
    let(:all_cases_survey_response) { build(:all_cases_survey_response, case: support_case) }
    let(:support_case) { build(:support_case, ref: "000001") }

    it "returns the linked case's reference" do
      expect(presenter.case_ref).to eq "000001"
    end
  end

  describe "#case_state" do
    let(:all_cases_survey_response) { build(:all_cases_survey_response, case: support_case) }
    let(:support_case) { build(:support_case, state: "on_hold") }

    it "returns the linked case's state" do
      expect(presenter.case_state).to eq "on_hold"
    end
  end

  describe "#case_resolved?" do
    let(:all_cases_survey_response) { build(:all_cases_survey_response, case: support_case) }
    let(:support_case) { build(:support_case, state:) }

    context "when the linked case is resolved" do
      let(:state) { "resolved" }

      it "returns true" do
        expect(presenter.case_resolved?).to eq true
      end
    end

    context "when the linked case is not resolved" do
      let(:state) { "initial" }

      it "returns false" do
        expect(presenter.case_resolved?).to eq false
      end
    end
  end

  describe "#previous_satisfaction_response" do
    context "when satisfaction_level is set" do
      let(:all_cases_survey_response) { build(:all_cases_survey_response) }

      it "returns downcased satisfaction level string" do
        expect(presenter.previous_satisfaction_response).to eq "satisfied"
      end
    end

    context "when satisfaction_level nil" do
      let(:all_cases_survey_response) { build(:all_cases_survey_response, satisfaction_level: nil) }

      it "returns nil" do
        expect(presenter.previous_satisfaction_response).to be_nil
      end
    end
  end
end
