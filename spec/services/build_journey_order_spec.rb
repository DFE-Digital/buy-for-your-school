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

    context "when the journey visits the same node twice" do
      around do |example|
        ClimateControl.modify(
          CONTENTFUL_PLANNING_START_ENTRY_ID: "5kZ9hIFDvNCEhjWs72SFwj"
        ) do
          example.run
        end
      end

      it "raises a rollbar event" do
        fake_entries = fake_contentful_entry_array(
          contentful_fixture_filename: "repeat-entry-example.json"
        )

        expect(Rollbar).to receive(:error)
          .with("A repeated Contentful entry was found in the same journey",
            contentful_url: ENV["CONTENTFUL_URL"],
            contentful_space_id: ENV["CONTENTFUL_SPACE"],
            contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
            contentful_entry_id: "5kZ9hIFDvNCEhjWs72SFwj")
          .and_call_original

        expect {
          described_class.new(
            entries: fake_entries,
            starting_entry_id: "5kZ9hIFDvNCEhjWs72SFwj"
          ).call
        }.to raise_error(BuildJourneyOrder::RepeatEntryDetected)
      end
    end
  end
end
