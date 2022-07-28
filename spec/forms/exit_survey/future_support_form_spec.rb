RSpec.describe ExitSurvey::FutureSupportForm do
  subject(:form) { described_class.new(future_support: "neither") }

  describe "#data" do
    it "returns form values ready for persisting" do
      expect(form.data).to eql(
        future_support: :neither,
      )
    end
  end

  describe "#future_support_options" do
    it "returns the future support options" do
      expect(form.future_support_options).to eq %w[strongly_agree agree neither disagree strongly_disagree]
    end
  end
end
