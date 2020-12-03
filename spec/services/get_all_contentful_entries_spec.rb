require "rails_helper"

RSpec.describe GetAllContentfulEntries do

  describe "#call" do
    it "requests and returns all entries from Contentful" do
      contentful_connector = instance_double(ContentfulConnector)
      expect(ContentfulConnector).to receive(:new)
        .and_return(contentful_connector)

      contentful_response = double(Contentful::Array)

      expect(contentful_connector).to receive(:get_all_entries)
        .and_return(contentful_response)

      result = described_class.new.call

      expect(result).to eq(contentful_response)

    end

    context "when the Contentful entries are not returned" do
      it "returns an error message" do
        contentful_connector = stub_contentful_connector

        allow(contentful_connector).to receive(:get_all_entries)
          .and_return(nil)

        expect { described_class.new.call }
          .to raise_error(GetAllContentfulEntries::NoEntriesFound)
      end

      it "raises a rollbar event" do
        contentful_client = stub_contentful_connector

        allow(contentful_client).to receive(:get_all_entries)
          .and_return(nil)

        expect(Rollbar).to receive(:warning)
          .with("Could not retrieve all entries from the following contentful environment.",
            contentful_url: ENV["CONTENTFUL_URL"],
            contentful_space_id: ENV["CONTENTFUL_SPACE"],
            contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"])
          .and_call_original
        expect { described_class.new.call }
          .to raise_error(GetAllContentfulEntries::NoEntriesFound)
      end
    end
  end
end
