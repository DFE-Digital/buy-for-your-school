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
  end
end
