describe FrameworkRequests::ProcurementConfidenceForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id) }

  let(:framework_request) { create(:framework_request, confidence_level: nil) }

  describe "validation" do
    describe "confidence_level" do
      it { is_expected.to validate_presence_of(:confidence_level) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:confidence_level]).to eq ["Select how confident you feel about running this procurement"]
        end
      end
    end
  end

  describe "#confidence_levels" do
    it "returns the available confidence levels" do
      expect(form.confidence_levels).to eq %w[very_confident confident slightly_confident somewhat_confident not_at_all_confident not_applicable]
    end
  end
end
