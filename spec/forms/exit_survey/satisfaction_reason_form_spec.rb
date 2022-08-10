RSpec.describe ExitSurvey::SatisfactionReasonForm do
  subject(:form) { described_class.new(satisfaction_text: "reasons") }

  describe "#data" do
    it "returns form values ready for persisting" do
      expect(form.data).to eql(
        satisfaction_text: "reasons",
      )
    end
  end
end
