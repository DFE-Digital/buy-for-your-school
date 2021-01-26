require "rails_helper"

RSpec.describe GetContentfulEntry do
  let(:contentful_journey_start_entry_id) { "1a2b3c4d5" }

  describe "#call" do
    it "requests and returns the required entry from Contentful" do
      contentful_connector = instance_double(ContentfulConnector)
      expect(ContentfulConnector).to receive(:new)
        .and_return(contentful_connector)

      contentful_response = double(Contentful::Entry, id: contentful_journey_start_entry_id)
      expect(contentful_connector).to receive(:get_entry_by_id)
        .with(contentful_journey_start_entry_id)
        .and_return(contentful_response)

      result = described_class.new(entry_id: contentful_journey_start_entry_id).call

      expect(result).to eq(contentful_response)
    end

    context "when the Contentful entry cannot be found" do
      it "returns an error message" do
        missing_entry_id = "345vsdf7"
        contentful_connector = stub_contentful_connector

        allow(contentful_connector).to receive(:get_entry_by_id)
          .with(missing_entry_id)
          .and_return(nil)

        expect { described_class.new(entry_id: missing_entry_id).call }
          .to raise_error(GetContentfulEntry::EntryNotFound)
      end

      it "raises a rollbar event" do
        contentful_client = stub_contentful_connector

        allow(contentful_client).to receive(:get_entry_by_id)
          .with(anything)
          .and_return(nil)

        expect(Rollbar).to receive(:warning)
          .with("The following Contentful entry identifier could not be found.",
            contentful_url: ENV["CONTENTFUL_URL"],
            contentful_space_id: ENV["CONTENTFUL_SPACE"],
            contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
            contentful_entry_id: "123")
          .and_call_original
        expect { described_class.new(entry_id: "123").call }
          .to raise_error(GetContentfulEntry::EntryNotFound)
      end
    end
  end
end
