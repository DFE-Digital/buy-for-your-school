RSpec.describe ExitSurvey::BetterQualityForm do
  subject(:form) { described_class.new(better_quality: "agree") }

  describe "#data" do
    it "returns form values ready for persisting" do
      expect(form.data).to eql(
        better_quality: :agree,
      )
    end
  end

  describe "#better_quality_options" do
    it "returns the better quality options" do
      expect(form.better_quality_options).to eq %w[strongly_agree agree neither disagree strongly_disagree]
    end
  end
end
