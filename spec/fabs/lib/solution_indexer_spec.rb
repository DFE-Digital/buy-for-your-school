require "rails_helper"

RSpec.describe SolutionIndexer do
  subject(:indexer) { described_class.new(id:) }

  let(:solution_index) { "solution-data" }
  let(:id) { "solution-123" }

  let(:es_client_mock) { instance_double(::OpenSearch::Client) }
  let(:primary_category) do
    instance_double(
      Category,
      id: "mock_id",
      title: "mock title",
      slug: " mock slug",
    )
  end

  let(:primary_category_hash) do
    {
      id: "mock_id",
      title: "mock title",
      slug: " mock slug",
    }
  end

  let(:solution_entry) do
    instance_double(
      Solution,
      id: "solution-123",
      title: "Test Solution",
      description: "A description.",
      summary: "A summary.",
      slug: "test-solution",
      provider_reference: "ref-123",
      primary_category:,
    )
  end

  before do
    allow(SearchClient).to receive(:instance).and_return(es_client_mock)
    allow(Solution).to receive(:find_by_id!).with(id).and_return(solution_entry)
  end

  describe "#index_document" do
    context "when the entry is found and indexing is successful" do
      it "calls the search client's index method" do
        allow(es_client_mock).to receive(:index).with(
          index: solution_index,
          id:,
          body: {
            id: solution_entry.id,
            title: solution_entry.title,
            description: solution_entry.description,
            summary: solution_entry.summary,
            slug: solution_entry.slug,
            provider_reference: solution_entry.provider_reference,
            primary_category: primary_category_hash,
          },
        ).and_return("result" => "created")
        expect(indexer.index_document).to be true
      end
    end

    context "when the entry is not found" do
      before do
        allow(Solution).to receive(:find_by_id!).with(id).and_return(nil)
      end

      it "does not call the search client's index method" do
        expect(es_client_mock).not_to receive(:index)
        expect(indexer.index_document).to be false
      end
    end

    context "when search indexing fails" do
      it "returns false when the client returns an unexpected result" do
        allow(es_client_mock).to receive(:index).and_return("result" => "failed")
        expect(indexer.index_document).to be false
      end
    end
  end

  describe "#delete_document" do
    context "when the document is successfully deleted" do
      it "calls the search client's delete method and returns true" do
        allow(es_client_mock).to receive(:delete).with(
          index: solution_index,
          id:,
        ).and_return("result" => "deleted")
        expect(indexer.delete_document).to be true
      end
    end

    context "when the document is not found" do
      it "rescues the NotFound error and returns true" do
        allow(es_client_mock).to receive(:delete).and_raise(OpenSearch::Transport::Transport::Errors::NotFound)
        expect(indexer.delete_document).to be true
      end
    end

    context "when search deletion fails" do
      it "returns false for an unexpected result" do
        allow(es_client_mock).to receive(:delete).and_return("result" => "unexpected")
        expect(indexer.delete_document).to be false
      end
    end
  end

  describe "#find_document" do
    let(:found_doc) { { "found" => true, "_id" => id, "_source" => { title: "Test Doc" } } }

    context "when the document is found" do
      it "calls the search client's get method and returns the document" do
        allow(es_client_mock).to receive(:get).with(
          index: solution_index,
          id:,
        ).and_return(found_doc)
        expect(indexer.find_document).to eq(found_doc)
      end
    end

    context "when the document is not found" do
      it "rescues the NotFound error and returns nil" do
        allow(es_client_mock).to receive(:get).and_raise(OpenSearch::Transport::Transport::Errors::NotFound)
        expect(indexer.find_document).to be_nil
      end
    end
  end
end
