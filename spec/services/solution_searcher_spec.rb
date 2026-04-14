RSpec.describe SolutionSearcher do
  subject(:searcher) { described_class.new(query:) }

  let(:query) { "laptops" }
  let(:client) { instance_double(SearchClient) }

  before do
    allow(SearchClient).to receive(:instance).and_return(client)
  end

  describe "#search" do
    let(:search_response) do
      {
        "hits" => {
          "hits" => hits,
        },
      }
    end
    let(:hits) { [] }

    before do
      allow(client).to receive(:search).and_return(search_response)
    end

    context "when OpenSearch returns no hits" do
      let(:hits) { [] }

      it "returns an empty array" do
        expect(searcher.search).to eq([])
      end
    end

    context "when OpenSearch returns hits" do
      let(:hits) do
        [
          { "_source" => { "id" => "presentable-solution" } },
          { "_source" => { "id" => "draft-solution" } },
        ]
      end
      let(:presentable_solution) { instance_double(Solution, presentable?: true) }
      let(:draft_solution) { instance_double(Solution, presentable?: false) }

      before do
        allow(Solution).to receive(:rehydrate_from_search)
          .with({ "id" => "presentable-solution" })
          .and_return(presentable_solution)
        allow(Solution).to receive(:rehydrate_from_search)
          .with({ "id" => "draft-solution" })
          .and_return(draft_solution)
      end

      it "rehydrates each hit and returns presentable solutions" do
        expect(searcher.search).to eq([presentable_solution])
      end
    end

    it "searches the solution index with a multi-match query" do
      allow(client).to receive(:search).and_return(search_response)

      expect(searcher.search).to eq([])
      expect(client).to have_received(:search).with(
        index: "solution-data",
        body: {
          query: {
            multi_match: {
              query: "laptops",
              fields: %w[title description summary slug provider_reference],
            },
          },
        },
      )
    end
  end
end
