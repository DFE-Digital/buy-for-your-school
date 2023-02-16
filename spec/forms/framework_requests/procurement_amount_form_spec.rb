describe FrameworkRequests::ProcurementAmountForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id) }

  let(:framework_request) { create(:framework_request, procurement_amount: nil) }

  describe "#format_amount" do
    subject(:form) { described_class.new(procurement_amount: "£2,543.90") }

    it "removes the pound sign and commas" do
      expect(form.format_amount).to eq "2543.90"
    end
  end

  describe "#procurement_amount_validation" do
    context "when the procurement amount is not a valid number" do
      subject(:form) { described_class.new(procurement_amount: "abc") }

      it "returns the right error message" do
        form.procurement_amount_validation

        expect(form).not_to be_valid
        expect(form.errors.messages[:procurement_amount]).to eq ["Enter a valid number"]
      end
    end

    context "when the procurement amount includes the pound sign" do
      subject(:form) { described_class.new(procurement_amount: "£12.95") }

      it "the value is interpreted correctly" do
        form.procurement_amount_validation

        expect(form).to be_valid
        expect(form.procurement_amount).to eq "12.95"
      end
    end

    context "when the procurement amount is too large" do
      subject(:form) { described_class.new(procurement_amount: "10000000") }

      it "returns the right error message" do
        form.procurement_amount_validation

        expect(form).not_to be_valid
        expect(form.errors.messages[:procurement_amount]).to eq ["The amount cannot be larger than 9,999,999.99"]
      end
    end
  end
end
