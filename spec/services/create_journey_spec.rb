require "rails_helper"

RSpec.describe CreateJourney do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_PLANNING_START_ENTRY_ID: "1UjQurSOi5MWkcRuGxdXZS"
    ) do
      example.run
    end
  end

  describe "#call" do
    it "creates a new journey" do
      expect { described_class.new(category: "catering").call }
        .to change { Journey.count }.by(1)
      expect(Journey.last.category).to eql("catering")
    end

    it "the sets the starting Contentful Entry ID" do
      described_class.new(category: "catering").call
      expect(Journey.last.next_entry_id).to eql("1UjQurSOi5MWkcRuGxdXZS")
    end

    it "stores a copy of the Liquid template" do
      fake_liquid_template = File.read("#{Rails.root}/spec/fixtures/specification_templates/catering.liquid")
      allow(File).to receive(:read).with("lib/specification_templates/catering.liquid")
        .and_return(fake_liquid_template)

      described_class.new(category: "catering").call

      expect(Journey.last.liquid_template)
        .to eql("<section id=\"blocks\">\n  {% if answer_55G5kpCLLL3h5yBQLiVlYy %}\n    <article>\n      <p class=\"govuk-body\">I'm the first article and should be seen</p>\n    </article>\n  {% endif %}\n</section>\n")
    end
  end
end
