describe AllCasesSurvey::SatisfactionReasonForm, type: :model do
  subject(:form) { described_class.new(**data) }

  describe "#data" do
    let(:data) { { satisfaction_text: "text" } }

    it "returns the instance variables relevant for persisting" do
      expect(form.data).to eq({ satisfaction_text: "text" })
    end
  end

  describe "#save!" do
    let(:all_cases_survey_response) { create(:all_cases_survey_response) }
    let(:data) { { id: all_cases_survey_response.id, satisfaction_text: "new reasons" } }

    it "updates the satisfaction reason text" do
      expect(all_cases_survey_response.satisfaction_text).to eq "reasons"

      form.save!

      expect(all_cases_survey_response.reload.satisfaction_text).to eq "new reasons"
    end
  end
end
