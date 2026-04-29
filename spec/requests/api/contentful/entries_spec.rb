require "rails_helper"

RSpec.describe "API Contentful entries", type: :request do
  let(:api_key) { "contentful-api-key" }
  let(:headers) { { "Authorization" => ActionController::HttpAuthentication::Token.encode_credentials(api_key) } }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CONTENTFUL_WEBHOOK_API_KEY").and_return(api_key)
    allow(Cache).to receive(:delete)
    allow_any_instance_of(Api::Contentful::EntriesController).to receive(:track_event)
  end

  it "deletes the cache entry and returns ok for an authenticated request" do
    post "/api/contentful/entry_updated", params: { entityId: "entry-123" }, headers: headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq("status" => "OK")
    expect(Cache).to have_received(:delete).with(key: "#{Cache::ENTRY_CACHE_KEY_PREFIX}:entry-123")
  end

  it "returns unauthorized without a valid token" do
    post "/api/contentful/entry_updated", params: { entityId: "entry-123" }

    expect(response).to have_http_status(:unauthorized)
    expect(Cache).not_to have_received(:delete)
  end
end
