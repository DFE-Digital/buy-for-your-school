require "rails_helper"

RSpec.describe "ContentfulWebhooks", :vcr, type: :request do
  # Define common parameters for a valid request.
  let(:entity_id) { "some_contentful_entry_id" }
  let(:valid_params) { { "entityId" => entity_id } }
  let(:solution_indexer_mock) { instance_double(SolutionIndexer) }
  let(:secret) { "a_valid_mocked_signature" }
  let(:valid_headers) do
    {
      "X-Contentful-Webhook-Signature" => secret,
    }
  end

  before do
    allow(SolutionIndexer).to receive(:new).and_return(solution_indexer_mock)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CONTENTFUL_WEBHOOK_SECRET").and_return(secret)
  end

  describe "POST #create" do
    context "when the document is successfully indexed" do
      before do
        allow(solution_indexer_mock).to receive(:index_document).and_return(true)
      end

      it "returns a 200 OK status" do
        post contentful_webhooks_path, params: valid_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end

      it "returns a success message" do
        post contentful_webhooks_path, params: valid_params, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Webhook for entry #{entity_id} processed successfully.")
      end
    end

    context "when the document fails to index" do
      before do
        allow(solution_indexer_mock).to receive(:index_document).and_return(false)
      end

      it "returns a 422 Unprocessable Entity status" do
        post contentful_webhooks_path, params: valid_params, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        post contentful_webhooks_path, params: valid_params, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Failed to index the document for id #{entity_id}.")
      end
    end

    context "when the entityId parameter is missing" do
      it "returns a 400 Bad Request status" do
        post contentful_webhooks_path, params: {}, headers: valid_headers
        expect(response).to have_http_status(:bad_request)
      end

      it "returns an error message" do
        post contentful_webhooks_path, params: {}, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("The 'entityId' is missing from the request.")
      end
    end
  end

  describe "#destroy" do
    context "when the document is successfully deleted" do
      before do
        allow(solution_indexer_mock).to receive(:delete_document).and_return(true)
      end

      it "returns a 200 OK status" do
        post delete_contentful_entry_path, params: valid_params, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end

      it "returns a success message" do
        post delete_contentful_entry_path, params: valid_params, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Webhook for entry #{entity_id} deletion processed successfully.")
      end
    end

    context "when the document fails to delete" do
      before do
        allow(solution_indexer_mock).to receive(:delete_document).and_return(false)
      end

      it "returns a 422 Unprocessable Entity status" do
        post delete_contentful_entry_path, params: valid_params, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns an error message" do
        post delete_contentful_entry_path, params: valid_params, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Failed to delete the document for id #{entity_id}.")
      end
    end

    context "when the entityId parameter is missing" do
      it "returns a 400 Bad Request status" do
        post delete_contentful_entry_path, params: {}, headers: valid_headers
        expect(response).to have_http_status(:bad_request)
      end

      it "returns an error message" do
        post delete_contentful_entry_path, params: {}, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("The 'entityId' is missing from the request.")
      end
    end
  end
end
