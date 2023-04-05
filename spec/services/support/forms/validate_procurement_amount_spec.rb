RSpec.describe Support::Forms::ValidateProcurementAmount do
  subject(:service) { described_class.new(amount) }

  describe "#new" do
    let(:amount) { "£5,689.44" }

    it "removes the pound sign and commas from the amount" do
      expect(service.amount).to eq "5689.44"
    end
  end

  describe "#invalid_number?" do
    context "when the amount is a valid number" do
      let(:amount) { "689.4" }

      it "returns false" do
        expect(service.invalid_number?).to eq false
      end
    end

    context "when the amount is an invalid number" do
      let(:amount) { "abc" }

      it "returns true" do
        expect(service.invalid_number?).to eq true
      end
    end
  end

  describe "#too_large?" do
    context "when the amount is not too large" do
      let(:amount) { "999552.87" }

      it "returns false" do
        expect(service.too_large?).to eq false
      end
    end

    context "when the amount is too large" do
      let(:amount) { "10000000" }

      it "returns true" do
        expect(service.too_large?).to eq true
      end
    end
  end
end
