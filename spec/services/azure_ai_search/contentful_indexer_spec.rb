require "rails_helper"

RSpec.describe AzureAiSearch::ContentfulIndexer do
  subject(:indexer) { described_class.new(client:) }

  let(:client) { instance_double(AzureAiSearch::Client, index_documents: { "value" => [{ "status" => true }] }) }
  let(:page) do
    FABS::Page.new(OpenStruct.new(
                     id: "page-1",
                     fields: { title: "Buying guidance", description: "Guidance", slug: "buying-guidance", parent: nil },
                   ))
  end

  it "indexes Contentful record types through the new content index" do
    indexer.index_all([page])

    expect(client).to have_received(:index_documents).with(
      index_name: "contentful-data",
      documents: [hash_including(content_type: "page", id: "page-page-1")],
    )
  end

  describe "#index_document" do
    it "indexes a page by id and content type" do
      allow(FABS::Page).to receive(:find_by_id!).with("page-1").and_return(page)

      expect(indexer.index_document("page-1", content_type: "page")).to be(true)

      expect(client).to have_received(:index_documents).with(
        index_name: "contentful-data",
        documents: [hash_including(content_type: "page", id: "page-page-1")],
      )
    end

    it "leaves an existing category document untouched when it no longer has a published solution" do
      allow(FABS::Category).to receive(:find_by_id!).with("category-1").and_raise(ContentfulRecordNotFoundError)

      expect {
        indexer.index_document("category-1", content_type: "category")
      }.to raise_error(ContentfulRecordNotFoundError)
      expect(client).not_to have_received(:index_documents)
    end
  end

  describe "#delete_document" do
    it "deletes the type-prefixed document id" do
      expect(indexer.delete_document("page-1", content_type: "page")).to be(true)

      expect(client).to have_received(:index_documents).with(
        index_name: "contentful-data",
        documents: [{ "@search.action": "delete", id: "page-page-1" }],
      )
    end
  end

  it "uses the existing category collection as its category source" do
    allow(Solution).to receive(:all).and_return([])
    allow(FABS::Category).to receive(:all).and_return([])
    allow(FABS::Page).to receive(:all).and_return([])
    allow(client).to receive(:search).and_return("value" => [])

    indexer.sync_all

    expect(FABS::Category).to have_received(:all)
    expect(FABS::Page).to have_received(:all)
  end
end
