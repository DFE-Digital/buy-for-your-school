RSpec.describe "Webhook upserts category", type: :request do
  before do
    has_valid_api_token
    stub_contentful_category(fixture_filename: "category-with-dynamic-liquid-template.json")
  end

  it "creates a new category" do
    fake_webhook_payload = {
      sys: {
        id: "contentful-category-entry",
      },
    }

    expect(Category.count).to be_zero

    post "/api/contentful/category",
         params: fake_webhook_payload,
         as: :json

    expect(response).to have_http_status(:ok)
    expect(Category.first.title).to eql "Catering"
  end
end
