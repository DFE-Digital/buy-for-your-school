require "rails_helper"

RSpec.describe AzureAiSearch::SolutionIndexer do
  subject(:indexer) { described_class.new(client:) }

  let(:client) { instance_double(AzureAiSearch::Client) }
  let(:category) { instance_double(FABS::Category, id: "cat-1", title: "Catering", slug: "catering") }
  let(:solution) do
    instance_double(
      Solution,
      id: "solution-1",
      title: "Catering solution",
      description: "Buy catering",
      summary: "Catering summary",
      slug: "catering-solution",
      provider_reference: "ref-1",
      primary_category: category,
      presentable?: true,
    )
  end

  describe "#index_all" do
    before do
      allow(client).to receive(:index_documents).and_return("value" => [{ "status" => true }])
    end

    it "sends presentable solutions to Azure AI Search" do
      indexer.index_all([solution])

      expect(client).to have_received(:index_documents).with(
        index_name: "solution-data",
        documents: [
          hash_including(
            "@search.action": "mergeOrUpload",
            id: "solution-1",
            title: "Catering solution",
            primary_category: {
              id: "cat-1",
              title: "Catering",
              slug: "catering",
            },
          ),
        ],
      )
    end

    context "when Contentful returns false for an unset text field" do
      let(:sent_documents) { [] }

      before do
        allow(solution).to receive(:provider_reference).and_return(false)
        allow(client).to receive(:index_documents) do |documents:, **|
          sent_documents.concat(documents)
          { "value" => [{ "status" => true }] }
        end
      end

      it "omits the field instead of sending a boolean to Azure AI Search" do
        indexer.index_all([solution])

        expect(sent_documents.first).to include(
          "@search.action": "mergeOrUpload",
          id: "solution-1",
        )
        expect(sent_documents.first).not_to include(:provider_reference)
      end
    end
  end
end
