require "rails_helper"

RSpec.describe "Contentful webhooks", type: :request do
  let(:entity_id) { "contentful-entry-123" }
  let(:secret) { "valid-signature" }
  let(:headers) { { "X-Contentful-Webhook-Signature" => secret } }
  let(:indexer) { instance_double(SolutionIndexer) }

  before do
    Flipper.enable(:ghbs_public_frontend)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("CONTENTFUL_WEBHOOK_SECRET").and_return(secret)
    allow(SolutionIndexer).to receive(:new).with(id: entity_id).and_return(indexer)
  end

  describe "POST /contentful_webhooks" do
    it "returns success when indexing succeeds" do
      allow(indexer).to receive(:index_document).and_return(true)

      post contentful_webhooks_path, params: { entityId: entity_id }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq("message" => "Webhook for entry #{entity_id} processed successfully.")
    end

    it "returns unprocessable_content when indexing fails" do
      allow(indexer).to receive(:index_document).and_return(false)

      post contentful_webhooks_path, params: { entityId: entity_id }, headers: headers

      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)).to eq("error" => "Failed to index the document for id #{entity_id}.")
    end

    it "returns bad_request when entityId is missing" do
      post contentful_webhooks_path, params: {}, headers: headers

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq("error" => "The 'entityId' is missing from the request.")
    end

    it "returns bad_request when only sys.id is provided" do
      allow(indexer).to receive(:index_document)

      post contentful_webhooks_path, params: { sys: { id: entity_id } }, headers: headers

      expect(response).to have_http_status(:bad_request)
      expect(indexer).not_to have_received(:index_document)
    end

    it "returns unauthorized when the signature is invalid" do
      post contentful_webhooks_path, params: { entityId: entity_id }, headers: { "X-Contentful-Webhook-Signature" => "wrong" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /delete_contentful_entry" do
    it "returns success when deletion succeeds" do
      allow(indexer).to receive(:delete_document).and_return(true)

      post delete_contentful_entry_path, params: { entityId: entity_id }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq("message" => "Webhook for entry #{entity_id} deletion processed successfully.")
    end

    it "returns unprocessable_content when deletion fails" do
      allow(indexer).to receive(:delete_document).and_return(false)

      post delete_contentful_entry_path, params: { entityId: entity_id }, headers: headers

      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)).to eq("error" => "Failed to delete the document for id #{entity_id}.")
    end

    it "returns bad_request when entityId is missing" do
      post delete_contentful_entry_path, params: {}, headers: headers

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq("error" => "The 'entityId' is missing from the request.")
    end

    it "returns bad_request when only sys.id is provided" do
      allow(indexer).to receive(:delete_document)

      post delete_contentful_entry_path, params: { sys: { id: entity_id } }, headers: headers

      expect(response).to have_http_status(:bad_request)
      expect(indexer).not_to have_received(:delete_document)
    end

    it "returns unauthorized when the signature is missing" do
      post delete_contentful_entry_path, params: { entityId: entity_id }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
