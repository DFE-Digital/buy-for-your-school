RSpec.describe ExitSurveyResponsePresenter do
  subject(:presenter) { described_class.new(exit_survey_response) }

  describe "#previous_satisfaction_response" do
    context "when satisfaction_level is set" do
      let(:exit_survey_response) { build(:exit_survey_response) }

      it "returns downcased satisfaction level string" do
        expect(presenter.previous_satisfaction_response).to eq "satisfied"
      end
    end

    context "when satisfaction_level nil" do
      let(:exit_survey_response) { build(:exit_survey_response, satisfaction_level: nil) }

      it "returns nil" do
        expect(presenter.previous_satisfaction_response).to be_nil
      end
    end
  end
end
