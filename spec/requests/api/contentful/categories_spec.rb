require "rails_helper"

RSpec.describe "API Contentful categories", type: :request do
  let(:api_key) { "contentful-api-key" }
  let(:headers) { { "Authorization" => ActionController::HttpAuthentication::Token.encode_credentials(api_key) } }
  let(:tracker) { instance_double(InsightsTracker, track_event: nil) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CONTENTFUL_WEBHOOK_API_KEY").and_return(api_key)
    allow(InsightsTracker).to receive(:new).and_return(tracker)
  end

  it "upserts the category from Contentful and returns ok" do
    contentful_category = double(
      "Contentful::Entry",
      title: "Catering",
      description: "Buy catering services",
      combined_specification_template: "Template body",
      id: "category-123",
      slug: "catering",
    )
    getter = instance_double(GetCategory, call: contentful_category)

    allow(GetCategory).to receive(:new).with(category_entry_id: "category-123").and_return(getter)
    allow(Category).to receive(:upsert).and_return([OpenStruct.new])

    post("/api/contentful/category", params: { sys: { id: "category-123" } }, headers:)

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq("status" => "OK")
    expect(Category).to have_received(:upsert).with(
      {
        title: "Catering",
        description: "Buy catering services",
        liquid_template: "Template body",
        contentful_id: "category-123",
        slug: "catering",
      },
      unique_by: :contentful_id,
      returning: %w[title description contentful_id slug liquid_template],
    )
  end

  it "returns unauthorized without a valid token" do
    post "/api/contentful/category", params: { sys: { id: "category-123" } }

    expect(response).to have_http_status(:unauthorized)
  end
end
