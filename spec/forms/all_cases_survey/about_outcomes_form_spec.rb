describe AllCasesSurvey::AboutOutcomesForm, type: :model do
  subject(:form) { described_class.new(**data) }

  describe "#data" do
    let(:data) { { about_outcomes_text: "text" } }

    it "returns the instance variables relevant for persisting" do
      expect(form.data).to eq({ about_outcomes_text: "text" })
    end
  end

  describe "#save!" do
    let(:all_cases_survey_response) { create(:all_cases_survey_response) }
    let(:data) { { id: all_cases_survey_response.id, about_outcomes_text: "better outcomes" } }

    it "updates the about outcomes text" do
      expect(all_cases_survey_response.about_outcomes_text).to eq "outcomes"

      form.save!

      expect(all_cases_survey_response.reload.about_outcomes_text).to eq "better outcomes"
    end
  end
end
