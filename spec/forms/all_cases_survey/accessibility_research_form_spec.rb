describe AllCasesSurvey::AccessibilityResearchForm, type: :model do
  subject(:form) { described_class.new(**data) }

  describe "#data" do
    let(:data) { { accessibility_research_opt_in: "true", accessibility_research_email: "test@example.com" } }

    it "returns the instance variables relevant for persisting" do
      expect(form.data).to eq({ accessibility_research_opt_in: "true", accessibility_research_email: "test@example.com" })
    end
  end

  describe "#save!" do
    let(:all_cases_survey_response) { create(:all_cases_survey_response) }
    let(:data) { { id: all_cases_survey_response.id, accessibility_research_opt_in: "true", accessibility_research_email: "new_email@example.com" } }

    it "updates the improvement text" do
      expect(all_cases_survey_response.accessibility_research_opt_in).to eq false
      expect(all_cases_survey_response.accessibility_research_email).to eq "test@email.com"

      form.save!

      expect(all_cases_survey_response.reload.accessibility_research_opt_in).to eq true
      expect(all_cases_survey_response.reload.accessibility_research_email).to eq "new_email@example.com"
    end
  end
end
