require "rails_helper"

RSpec.describe CreateJourney do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_PLANNING_START_ENTRY_ID: "contentful-starting-step"
    ) do
      example.run
    end
  end

  describe "#call" do
    it "creates a new journey" do
      stub_get_contentful_entries(
        entry_id: "contentful-starting-step",
        fixture_filename: "closed-path-with-multiple-example.json"
      )
      expect { described_class.new(category: "catering").call }
        .to change { Journey.count }.by(1)
      expect(Journey.last.category).to eql("catering")
    end

    it "stores a copy of the Liquid template" do
      stub_get_contentful_entries(
        entry_id: "contentful-starting-step",
        fixture_filename: "closed-path-with-multiple-example.json"
      )
      fake_liquid_template = File.read("#{Rails.root}/spec/fixtures/specification_templates/basic_catering.liquid")
      finder = instance_double(FindLiquidTemplate)
      allow(FindLiquidTemplate).to receive(:new).with(category: "catering")
        .and_return(finder)
      allow(finder).to receive(:call).and_return(fake_liquid_template)

      described_class.new(category: "catering").call

      expect(Journey.last.liquid_template)
        .to eql("<article id=\"specification\">\n  {% if answer_contentful-starting-step %}\n    <section>\n      <p class=\"govuk-body\">I'm the first article and should be seen</p>\n    </section>\n  {% endif %}\n</article>\n")
    end
  end
end
