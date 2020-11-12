require "rails_helper"

RSpec.describe GetContentfulEntry do
  let(:contentful_url) { "preview.contentful" }
  let(:contentful_space) { "abc" }
  let(:contentful_environment) { "test" }
  let(:contentful_access_token) { "123" }
  let(:contentful_planning_start_entry_id) { "1a2b3c4d5" }

  around do |example|
    ClimateControl.modify(
      CONTENTFUL_URL: contentful_url,
      CONTENTFUL_SPACE: contentful_space,
      CONTENTFUL_ENVIRONMENT: contentful_environment,
      CONTENTFUL_ACCESS_TOKEN: contentful_access_token,
      CONTENTFUL_PLANNING_START_ENTRY_ID: contentful_planning_start_entry_id
    ) do
      example.run
    end
  end

  describe "#call" do
    it "returns the contents of Contentful fixture (for now)" do
      contentful_client = instance_double(Contentful::Client)
      expect(Contentful::Client).to receive(:new)
        .with(api_url: contentful_url,
              space: contentful_space,
              environment: contentful_environment,
              access_token: contentful_access_token)
        .and_return(contentful_client)

      contentful_response = double(Contentful::Entry, id: contentful_planning_start_entry_id)
      expect(contentful_client).to receive(:entry)
        .with(contentful_planning_start_entry_id)
        .and_return(contentful_response)

      result = described_class.new(entry_id: contentful_planning_start_entry_id).call

      expect(result).to eq(contentful_response)
    end

    context "when the Contentful entry cannot be found" do
      it "returns an error message" do
        missing_entry_id = "345vsdf7"
        contentful_client = stub_contentful_client

        allow(contentful_client).to receive(:entry)
          .with(missing_entry_id)
          .and_return(nil)

        expect { described_class.new(entry_id: missing_entry_id).call }
          .to raise_error(GetContentfulEntry::EntryNotFound)
      end

      it "raises a rollbar event" do
        contentful_client = stub_contentful_client

        allow(contentful_client).to receive(:entry)
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
