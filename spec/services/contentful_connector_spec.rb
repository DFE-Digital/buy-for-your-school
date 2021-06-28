require "rails_helper"

RSpec.describe ContentfulConnector do
  let(:contentful_url) { "preview.contentful" }
  let(:contentful_space) { "abc" }
  let(:contentful_environment) { "test" }
  let(:contentful_access_token) { "123" }

  around do |example|
    ClimateControl.modify(
      CONTENTFUL_URL: contentful_url,
      CONTENTFUL_SPACE: contentful_space,
      CONTENTFUL_ENVIRONMENT: contentful_environment,
      CONTENTFUL_ACCESS_TOKEN: contentful_access_token,
    ) do
      example.run
    end
  end

  describe "#get_entry_by_id" do
    it "returns a Contentful entry by making a call to Contentful" do
      contentful_client = instance_double(Contentful::Client)
      allow(Contentful::Client).to receive(:new)
        .with(api_url: contentful_url,
              space: contentful_space,
              environment: contentful_environment,
              access_token: contentful_access_token)
        .and_return(contentful_client)

      contentful_response = double(Contentful::Entry, id: "123")
      allow(contentful_client).to receive(:entry)
        .with("123")
        .and_return(contentful_response)

      result = described_class.new.get_entry_by_id("123")

      expect(result).to eq(contentful_response)
    end
  end

  describe "#get_all_entries" do
    it "returns all Contentful entries by making a call to Contentful" do
      contentful_client = instance_double(Contentful::Client)
      allow(Contentful::Client).to receive(:new)
        .with(api_url: contentful_url,
              space: contentful_space,
              environment: contentful_environment,
              access_token: contentful_access_token)
        .and_return(contentful_client)

      contentful_response = instance_double(Contentful::Array)
      allow(contentful_client).to receive(:entries)
        .and_return(contentful_response)

      result = described_class.new.get_all_entries

      expect(result).to eq(contentful_response)
    end
  end
end
