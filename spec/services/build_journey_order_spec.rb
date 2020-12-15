require "rails_helper"

RSpec.describe BuildJourneyOrder do
  describe "#call" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_PLANNING_START_ENTRY_ID: "5kZ9hIFDvNCEhjWs72SFwj"
      ) do
        example.run
      end
    end

    context "when there are multiple entries" do
      it "returns each ID in the order they appear" do
        fake_entries = fake_contentful_entry_array(
          contentful_fixture_filename: "closed-path-with-multiple-example.json"
        )

        result = described_class.new(
          entries: fake_entries,
          starting_entry_id: "5kZ9hIFDvNCEhjWs72SFwj"
        ).call

        expect(result).to match([fake_entries.first, fake_entries.last])
      end
    end
  end
end
