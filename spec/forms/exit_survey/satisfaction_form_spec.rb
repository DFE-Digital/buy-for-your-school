RSpec.describe ExitSurvey::SatisfactionForm do
  subject(:form) { described_class.new(satisfaction_level: "satisfied") }

  describe "#data" do
    it "returns form values ready for persisting" do
      expect(form.data).to eql(
        satisfaction_level: :satisfied,
      )
    end
  end

  describe "#satisfaction_options" do
    it "returns the satisfaction options" do
      expect(form.satisfaction_options).to eq %w[very_satisfied satisfied neither dissatisfied very_dissatisfied]
    end
  end
end
