RSpec.describe ArrayBuilder do
  subject(:array_builder) { described_class }

  describe "#self.call" do
    context "when input is nil" do
      it "returns nil" do
        value = array_builder.call(nil)
        expect(value).to eq nil
      end
    end

    context "when input is blank" do
      it "returns an empty array" do
        value = array_builder.call("")
        expect(value).to eq []
      end
    end

    context "when input is a JSON array" do
      it "returns it as an array" do
        value = array_builder.call("[\"message\"]")
        expect(value).to eq %w[message]
      end
    end
  end
end
