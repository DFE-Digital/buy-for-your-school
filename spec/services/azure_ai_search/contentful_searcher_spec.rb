require "rails_helper"

RSpec.describe AzureAiSearch::ContentfulSearcher do
  subject(:searcher) { described_class.new(query: "catering", client:) }

  let(:client) { instance_double(AzureAiSearch::Client) }
  let(:response) do
    {
      "value" => [
        {
          "@search.score" => 1.2,
          "id" => "category-catering",
          "content_type" => "category",
          "title" => "Catering",
          "description" => "Catering services",
          "slug" => "catering",
        },
      ],
    }
  end

  before do
    allow(client).to receive(:search).and_return(response)
  end

  it "searches all indexed content types and returns typed results" do
    expect(searcher.search).to contain_exactly(
      have_attributes(content_type: "category", title: "Catering", description: "Catering services", slug: "catering"),
    )
    expect(client).to have_received(:search).with(
      index_name: "contentful-data",
      body: hash_including(
        search: "catering",
        select: "id,content_type,title,description,slug,primary_category",
        queryType: "simple",
      ),
    )
  end

  it "uses the semantic configuration when semantic search is enabled" do
    ClimateControl.modify(AZURE_AI_SEARCH_QUERY_TYPE: "semantic") do
      searcher.search
    end

    expect(client).to have_received(:search).with(
      index_name: "contentful-data",
      body: hash_including(queryType: "semantic", semanticConfiguration: "contentful-v1"),
    )
  end
end
