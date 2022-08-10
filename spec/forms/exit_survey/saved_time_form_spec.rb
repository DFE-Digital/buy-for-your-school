RSpec.describe ExitSurvey::SavedTimeForm do
  subject(:form) { described_class.new(saved_time: "disagree") }

  describe "#data" do
    it "returns form values ready for persisting" do
      expect(form.data).to eql(
        saved_time: :disagree,
      )
    end
  end

  describe "#saved_time_options" do
    it "returns the saved time options" do
      expect(form.saved_time_options).to eq %w[strongly_agree agree neither disagree strongly_disagree]
    end
  end
end
