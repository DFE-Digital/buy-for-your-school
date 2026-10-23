require "rails_helper"

RSpec.describe Energy::GasPriceFormatting do
  describe ".format" do
    it "rounds prices to three decimal places" do
      expect(described_class.format(2.8685)).to eq("2.869")
      expect(described_class.format(3.624)).to eq("3.624")
      expect(described_class.format(0.1)).to eq("0.100")
    end
  end
end
