require "rails_helper"

RSpec.describe FindLiquidTemplate do
  describe "#call" do
    context "when in development" do
      it "loads the development liquid template" do
        category = "catering"
        expect(File).to receive(:read).with("lib/specification_templates/#{category}.development.liquid")
        described_class.new(category: category, environment: "development").call
      end
    end

    context "when in staging" do
      it "loads the staging liquid template" do
        category = "catering"
        expect(File).to receive(:read).with("lib/specification_templates/#{category}.staging.liquid")
        described_class.new(category: category, environment: "staging").call
      end
    end

    context "when in production" do
      it "loads the production liquid template" do
        category = "catering"
        expect(File).to receive(:read).with("lib/specification_templates/#{category}.production.liquid")
        described_class.new(category: category, environment: "production").call
      end
    end
  end
end
