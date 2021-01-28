require "rails_helper"

RSpec.describe CreateJourney do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID: "contentful-category-entry"
    ) do
      example.run
    end
  end

  describe "#call" do
    it "creates a new journey" do
      stub_contentful_category(
        fixture_filename: "category-with-no-steps.json",
        stub_steps: false
      )
      expect { described_class.new(category_name: "catering").call }
        .to change { Journey.count }.by(1)
      expect(Journey.last.category).to eql("catering")
    end

    it "stores a copy of the Liquid template" do
      stub_contentful_category(
        fixture_filename: "category-with-liquid-template.json"
      )

      described_class.new(category_name: "catering").call

      expect(Journey.last.liquid_template)
        .to eql("<article id='specification'><h1>Liquid {{templating}}</h1></article>")
    end
  end
end
