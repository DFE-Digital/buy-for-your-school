describe AllCasesSurvey::OutcomeAchievedForm, type: :model do
  subject(:form) { described_class.new(**data) }

  describe "#data" do
    let(:data) { { outcome_achieved: "disagree" } }

    it "returns the instance variables relevant for persisting" do
      expect(form.data).to eq({ outcome_achieved: "disagree" })
    end
  end

  describe "#save!" do
    let(:all_cases_survey_response) { create(:all_cases_survey_response) }
    let(:data) { { id: all_cases_survey_response.id, outcome_achieved: "disagree" } }

    it "updates the outcome achieved value" do
      expect(all_cases_survey_response.outcome_achieved).to eq "agree"

      form.save!

      expect(all_cases_survey_response.reload.outcome_achieved).to eq "disagree"
    end
  end

  describe "#outcome_achieved_options" do
    let(:data) { { outcome_achieved: "disagree" } }

    it "returns the outcome achieved options" do
      expect(form.outcome_achieved_options).to eq %w[strongly_agree agree neither disagree strongly_disagree]
    end
  end
end
