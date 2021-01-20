require "rails_helper"

RSpec.describe FindLiquidTemplate do
  describe "#call" do
    context "when the Liquid contents are invalid (using the gems own parser)" do
      it "raises an error" do
        fake_liquid_template = File.read("#{Rails.root}/spec/fixtures/specification_templates/invalid.liquid")

        finder = described_class.new(category: "catering")
        allow(finder).to receive(:file).and_return(fake_liquid_template)

        expect { finder.call }.to raise_error(FindLiquidTemplate::InvalidLiquidSyntax)
      end

      it "sends an error to rollbar" do
        fake_liquid_template = File.read("#{Rails.root}/spec/fixtures/specification_templates/invalid.liquid")

        finder = described_class.new(category: "catering")
        allow(finder).to receive(:file).and_return(fake_liquid_template)

        expect(Rollbar).to receive(:error)
          .with("A user couldn't start a journey because of an invalid Specification",
            contentful_url: ENV["CONTENTFUL_URL"],
            contentful_space_id: ENV["CONTENTFUL_SPACE"],
            contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
            category: "catering").and_call_original

        expect { finder.call }.to raise_error(FindLiquidTemplate::InvalidLiquidSyntax)
      end
    end

    context "when in development" do
      it "loads the development liquid template" do
        category = "catering"
        expect(File).to receive(:read).with("lib/specification_templates/#{category}.development.liquid").at_least(:once)
        described_class.new(category: category, environment: "development").call
      end
    end

    context "when in staging" do
      it "loads the staging liquid template" do
        category = "catering"
        expect(File).to receive(:read).with("lib/specification_templates/#{category}.staging.liquid").at_least(:once)
        described_class.new(category: category, environment: "staging").call
      end
    end

    context "when in production" do
      it "loads the production liquid template" do
        category = "catering"
        expect(File).to receive(:read).with("lib/specification_templates/#{category}.production.liquid").at_least(:once)
        described_class.new(category: category, environment: "production").call
      end
    end
  end
end
