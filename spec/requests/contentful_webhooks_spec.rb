require "rails_helper"

RSpec.describe "Contentful webhooks", type: :request do
  let(:entity_id) { "contentful-entry-123" }
  let(:secret) { "valid-signature" }
  let(:topic) { "ContentManagement.Entry.publish" }
  let(:headers) do
    {
      "X-Contentful-Webhook-Signature" => secret,
      "X-Contentful-Topic" => topic,
    }
  end
  let(:payload) do
    {
      sys: {
        id: entity_id,
        contentType: {
          sys: {
            id: content_type,
          },
        },
      },
    }
  end
  let(:content_type) { "solution" }
  let(:indexer) { instance_double(SolutionIndexer) }
  let(:azure_indexer) { instance_double(AzureAiSearch::SolutionIndexer) }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("CONTENTFUL_WEBHOOK_SECRET").and_return(secret)
    allow(SolutionIndexer).to receive(:new).with(id: entity_id).and_return(indexer)
    allow(RedirectMatcher).to receive(:invalidate_cache!)
  end

  describe "POST /contentful_webhooks" do
    context "when publishing a solution" do
      it "returns success when indexing succeeds" do
        allow(indexer).to receive(:index_document).and_return(true)

        post(contentful_webhooks_path, params: payload, headers:)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq("message" => "Webhook for entry #{entity_id} processed successfully.")
      end

      it "returns unprocessable_content when indexing fails" do
        allow(indexer).to receive(:index_document).and_return(false)

        post(contentful_webhooks_path, params: payload, headers:)

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq("error" => "Failed to index the document for id #{entity_id}.")
      end

      context "when Azure AI Search is enabled" do
        before do
          allow(Flipper).to receive(:enabled?).and_return(false)
          allow(Flipper).to receive(:enabled?).with(:azure_ai_search).and_return(true)
          allow(AzureAiSearch::SolutionIndexer).to receive(:new).and_return(azure_indexer)
        end

        it "indexes the document through Azure AI Search" do
          allow(azure_indexer).to receive(:index_document).with(entity_id).and_return(true)

          post(contentful_webhooks_path, params: payload, headers:)

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq("message" => "Webhook for entry #{entity_id} processed successfully.")
          expect(azure_indexer).to have_received(:index_document).with(entity_id)
        end
      end
    end

    context "when deleting a solution" do
      let(:topic) { "ContentManagement.Entry.delete" }

      it "returns success when deletion succeeds" do
        allow(indexer).to receive(:delete_document).and_return(true)

        post(contentful_webhooks_path, params: payload, headers:)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq("message" => "Webhook for entry #{entity_id} deletion processed successfully.")
      end

      it "returns unprocessable_content when deletion fails" do
        allow(indexer).to receive(:delete_document).and_return(false)

        post(contentful_webhooks_path, params: payload, headers:)

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq("error" => "Failed to delete the document for id #{entity_id}.")
      end

      context "when Azure AI Search is enabled" do
        before do
          allow(Flipper).to receive(:enabled?).and_return(false)
          allow(Flipper).to receive(:enabled?).with(:azure_ai_search).and_return(true)
          allow(AzureAiSearch::SolutionIndexer).to receive(:new).and_return(azure_indexer)
        end

        it "deletes the document through Azure AI Search" do
          allow(azure_indexer).to receive(:delete_document).with(entity_id).and_return(true)

          post(contentful_webhooks_path, params: payload, headers:)

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq("message" => "Webhook for entry #{entity_id} deletion processed successfully.")
          expect(azure_indexer).to have_received(:delete_document).with(entity_id)
        end
      end
    end

    context "when publishing a redirect" do
      let(:content_type) { "redirect" }

      it "invalidates the redirect cache" do
        post(contentful_webhooks_path, params: payload, headers:)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq("message" => "Webhook for redirect entry #{entity_id} processed successfully.")
        expect(RedirectMatcher).to have_received(:invalidate_cache!)
      end
    end

    context "when unpublishing a redirect" do
      let(:content_type) { "redirect" }
      let(:topic) { "ContentManagement.Entry.unpublish" }

      it "invalidates the redirect cache" do
        post(contentful_webhooks_path, params: payload, headers:)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq("message" => "Webhook for redirect entry #{entity_id} deletion processed successfully.")
        expect(RedirectMatcher).to have_received(:invalidate_cache!)
      end
    end

    context "when the entry id is missing" do
      let(:payload) { { sys: { contentType: { sys: { id: content_type } } } } }

      it "returns bad_request" do
        post(contentful_webhooks_path, params: payload, headers:)

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq("error" => "The entry id is missing from the request.")
      end
    end

    context "when the topic is unsupported" do
      let(:topic) { "ContentManagement.Entry.auto_save" }

      it "returns success and ignores the webhook" do
        post(contentful_webhooks_path, params: payload, headers:)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq("message" => "Ignoring unsupported webhook topic #{topic} for entry #{entity_id}.")
      end
    end

    context "when the content type is unsupported" do
      let(:content_type) { "category" }

      it "returns success and ignores the webhook" do
        post(contentful_webhooks_path, params: payload, headers:)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq("message" => "Ignoring unsupported content type #{content_type} for entry #{entity_id}.")
      end
    end

    context "when the signature is invalid" do
      it "returns unauthorized" do
        post contentful_webhooks_path, params: payload, headers: headers.merge("X-Contentful-Webhook-Signature" => "wrong")

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
