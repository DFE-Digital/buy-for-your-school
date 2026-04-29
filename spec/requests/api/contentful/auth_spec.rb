require "rails_helper"

RSpec.describe "API Contentful auth", type: :request do
  let(:api_key) { "contentful-api-key" }
  let(:headers) { { "Authorization" => ActionController::HttpAuthentication::Token.encode_credentials(api_key) } }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CONTENTFUL_WEBHOOK_API_KEY").and_return(api_key)
  end

  it "returns ok with a valid token" do
    post("/api/contentful/auth", headers:)

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq("status" => "OK")
  end

  it "returns unauthorized without a valid token" do
    post "/api/contentful/auth"

    expect(response).to have_http_status(:unauthorized)
  end
end
