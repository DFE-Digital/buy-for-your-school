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
    let(:validator) { double("validator") }

    before do
      allow(Support::Forms::ValidateProcurementAmount).to receive(:new).and_return(validator)
    end

    context "when the procurement amount is not a valid number" do
      subject(:form) { described_class.new(procurement_amount: "abc") }

      before do
        # allow(validator).to receive(:invalid_number?).and_return(true)
        allow(validator).to receive(:too_large?).and_return(false)
      end

      it "returns the right error message" do
        expect(form).not_to be_valid
        expect(form.errors.messages[:procurement_amount]).to eq ["Enter a valid number"]
        # expect(validator).to have_received(:invalid_number?).once
      end
    end

    context "when the procurement amount is too large" do
      subject(:form) { described_class.new(procurement_amount: "10000000") }

      before do
        # allow(validator).to receive(:invalid_number?).and_return(false)
        allow(validator).to receive(:too_large?).and_return(true)
      end

      it "returns the right error message" do
        expect(form).not_to be_valid
        expect(form.errors.messages[:procurement_amount]).to eq ["The amount cannot be larger than 9,999,999.99"]
        expect(validator).to have_received(:too_large?).once
      end
    end
  end
end
