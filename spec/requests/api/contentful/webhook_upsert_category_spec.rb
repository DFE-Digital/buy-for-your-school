RSpec.describe "Webhook upserts category", type: :request do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_WEBHOOK_API_KEY: "an API key",
      ) do
      example.run
    end
  end


  let!(:contentful_category_stub) { stub_contentful_category(fixture_filename: "category-with-dynamic-liquid-template.json") }

  before do
    allow(contentful_category).to receive(:new).and_return(contentful_category_stub)
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

    post "/api/contentful/category",
         params: fake_contentful_webhook_payload,
         headers: headers,
         as: :json

    ## TODO ensure controller var 'contentful_category' is stubbed with contentful_category_stub
    ## check that Category is present with Catertering title
    expect(response).to have_http_status(:ok)
  end



end
