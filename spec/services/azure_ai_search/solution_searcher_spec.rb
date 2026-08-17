require "rails_helper"

RSpec.describe AzureAiSearch::SolutionSearcher do
  subject(:searcher) { described_class.new(query:, client:) }

  let(:query) { "laptops" }
  let(:client) { instance_double(AzureAiSearch::Client) }

  before do
    allow(client).to receive(:search).and_return(search_response)
  end

  describe "#search" do
    let(:search_response) do
      {
        "value" => [
          {
            "@search.score" => 1.2,
            "id" => "presentable-solution",
            "title" => "Laptop buying option",
          },
          {
            "@search.score" => 0.8,
            "id" => "draft-solution",
          },
        ],
      }
    end
    let(:presentable_solution) { instance_double(Solution, presentable?: true) }
    let(:draft_solution) { instance_double(Solution, presentable?: false) }

    before do
      allow(Solution).to receive(:rehydrate_from_search)
        .with({ "id" => "presentable-solution", "title" => "Laptop buying option" })
        .and_return(presentable_solution)
      allow(Solution).to receive(:rehydrate_from_search)
        .with({ "id" => "draft-solution" })
        .and_return(draft_solution)
    end

    it "queries Azure AI Search and returns presentable solutions" do
      expect(searcher.search).to eq([presentable_solution])
      expect(client).to have_received(:search).with(
        index_name: "solution-data",
        body: hash_including(
          search: "laptops",
          queryType: "simple",
        ),
      )
    end

    context "when semantic search is enabled" do
      around do |example|
        ClimateControl.modify(AZURE_AI_SEARCH_QUERY_TYPE: "semantic") do
          example.run
        end
      end

      it "sends semantic search parameters" do
        searcher.search

        expect(client).to have_received(:search).with(
          index_name: "solution-data",
          body: hash_including(
            queryType: "semantic",
            semanticConfiguration: "solutions-v1",
            captions: "extractive|highlight-true",
          ),
        )
      end
    end
  end
end
