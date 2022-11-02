describe AllCasesSurvey::ImprovementsForm, type: :model do
  subject(:form) { described_class.new(**data) }

  describe "#data" do
    let(:data) { { improve_text: "text" } }

    it "returns the instance variables relevant for persisting" do
      expect(form.data).to eq({ improve_text: "text" })
    end
  end

  describe "#save!" do
    let(:all_cases_survey_response) { create(:all_cases_survey_response) }
    let(:data) { { id: all_cases_survey_response.id, improve_text: "new improvements" } }

    it "updates the improvement text" do
      expect(all_cases_survey_response.improve_text).to eq "improvements"

      form.save!

      expect(all_cases_survey_response.reload.improve_text).to eq "new improvements"
    end
  end
end
