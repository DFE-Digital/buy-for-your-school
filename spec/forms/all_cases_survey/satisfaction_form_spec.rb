describe AllCasesSurvey::SatisfactionForm, type: :model do
  subject(:form) { described_class.new(**data) }

  describe "#data" do
    let(:data) { { satisfaction_level: "neither" } }

    it "returns the instance variables relevant for persisting" do
      expect(form.data).to eq({ satisfaction_level: "neither" })
    end
  end

  describe "#save!" do
    let(:all_cases_survey_response) { create(:all_cases_survey_response) }
    let(:data) { { id: all_cases_survey_response.id, satisfaction_level: "neither" } }

    it "updates the satisfaction level" do
      expect(all_cases_survey_response.satisfaction_level).to eq "satisfied"

      form.save!

      expect(all_cases_survey_response.reload.satisfaction_level).to eq "neither"
    end
  end

  describe "#satisfaction_options" do
    let(:data) { { satisfaction_level: "neither" } }

    it "returns the outcome achieved options" do
      expect(form.satisfaction_options).to eq %w[very_satisfied satisfied neither dissatisfied very_dissatisfied]
    end
  end
end
