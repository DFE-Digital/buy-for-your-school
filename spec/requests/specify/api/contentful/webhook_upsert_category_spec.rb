RSpec.describe "Webhook upserts category", type: :request do
  let(:fake_webhook_payload) do
    {
      sys: {
        id: "contentful-category-entry",
      },
    }
  end

  before do
    has_valid_api_token
    stub_contentful_category(fixture_filename: "category-with-dynamic-liquid-template.json")
  end

  it "creates a new category" do
    expect(Category.count).to be_zero

    post "/api/contentful/category",
         params: fake_webhook_payload,
         as: :json

    expect(response).to have_http_status(:ok)
    expect(Category.first.title).to eql "Catering"
    expect(Category.first.slug).to eql "catering"
  end

  it "updates an existing category" do
    create(:category, contentful_id: "contentful-category-entry", title: "Test title", description: "Test description", liquid_template: "{}", slug: "test_slug")
    expect(Category.count).to eq 1

    post "/api/contentful/category",
         params: fake_webhook_payload,
         as: :json

    expect(response).to have_http_status(:ok)
    expect(Category.count).to eq 1
    expect(Category.first.title).to eql "Catering"
    expect(Category.first.description).to eql "Catering description"
    expect(Category.first.liquid_template).to match(/<article id='specification'>/)
    expect(Category.first.contentful_id).to eql "contentful-category-entry"
    expect(Category.first.slug).to eql "catering"
  end
end
