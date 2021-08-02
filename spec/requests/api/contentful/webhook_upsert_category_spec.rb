RSpec.describe "Webhook upserts category", type: :request do

  around do |example|
    ClimateControl.modify(CONTENTFUL_WEBHOOK_API_KEY: "an API key") do
      example.run
    end
  end

  before do
    stub_contentful_category(fixture_filename: "category-with-dynamic-liquid-template.json")
  end

  it "creates a new category" do
    credentials = ActionController::HttpAuthentication::Token
                    .encode_credentials(ENV["CONTENTFUL_WEBHOOK_API_KEY"])
    headers = { "AUTHORIZATION" => credentials }

    fake_contentful_webhook_payload = {
      sys: {
        id: "contentful-category-entry",
      },
    }

    expect(Category.count).to be_zero

    post "/api/contentful/category",
         params: fake_contentful_webhook_payload,
         headers: headers,
         as: :json

    expect(response).to have_http_status(:ok)

    expect(Category.first.title).to eql "Catering"
  end
end
