require "rails_helper"

RSpec.describe AzureAiSearch::Client do
  subject(:client) do
    described_class.new(
      endpoint: "https://devghbs-search.search.windows.net",
      api_key: "primary-key",
    )
  end

  describe "#create_index" do
    it "posts the index schema to Azure AI Search" do
      request = stub_request(:post, "https://devghbs-search.search.windows.net/indexes?api-version=2024-07-01")
        .with(
          body: { name: "solution-data" }.to_json,
          headers: { "api-key" => "primary-key", "Content-Type" => "application/json" },
        )
        .to_return(status: 201, body: { name: "solution-data" }.to_json)

      expect(client.create_index(body: { name: "solution-data" })).to eq("name" => "solution-data")
      expect(request).to have_been_requested
    end
  end

  describe "#index_exists?" do
    it "returns true when Azure AI Search returns the index" do
      stub_request(:get, "https://devghbs-search.search.windows.net/indexes('solution-data')?api-version=2024-07-01")
        .to_return(status: 200, body: { name: "solution-data" }.to_json)

      expect(client.index_exists?(index_name: "solution-data")).to be true
    end

    it "returns false when Azure AI Search returns a 404" do
      stub_request(:get, "https://devghbs-search.search.windows.net/indexes('solution-data')?api-version=2024-07-01")
        .to_return(status: 404, body: { error: { message: "Not found" } }.to_json)

      expect(client.index_exists?(index_name: "solution-data")).to be false
    end
  end

  describe "#document_count" do
    it "returns the document count from Azure AI Search" do
      stub_request(:get, "https://devghbs-search.search.windows.net/indexes('solution-data')/docs/$count?api-version=2024-07-01")
        .to_return(status: 200, body: "64")

      expect(client.document_count(index_name: "solution-data")).to eq(64)
    end
  end
end
