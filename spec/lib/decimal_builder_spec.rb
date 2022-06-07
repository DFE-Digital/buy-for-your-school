RSpec.describe DecimalBuilder do
  subject(:decimal_builder) { described_class }

  describe "call" do
    context "when input is a numeric string" do
      it "gives it two decimal places" do
        value = described_class.call("34000")
        expect(value).to eq "34000.00"
      end
    end

    context "when input is a numeric string with commas" do
      it "gives it two decimal places and removes the commas" do
        value = described_class.call("34,000")
        expect(value).to eq "34000.00"
      end
    end

    context "when input is a non-numeric string" do
      it "returns an empty string" do
        value = described_class.call("twenty")
        expect(value).to eq ""
      end
    end

    context "when input is nil" do
      it "returns an empty string" do
        value = described_class.call("")
        expect(value).to eq ""
      end
    end
  end
end
