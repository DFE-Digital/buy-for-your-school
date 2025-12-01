require "rails_helper"

RSpec.describe "Authenticate API User", type: :request do
  # TODO: refactor this into a concern
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_WEBHOOK_API_KEY: "an API key",
    ) do
      example.run
    end
  end

  it "authenticates api user with valid api key" do
    credentials = ActionController::HttpAuthentication::Token
                    .encode_credentials(ENV["CONTENTFUL_WEBHOOK_API_KEY"])
    headers = { "AUTHORIZATION" => credentials }

    post "/api/contentful/auth",
         headers:,
         as: :json

    expect(response).to have_http_status(:ok)
  end

  it "returns unauthorized if not key supplied" do
    post "/api/contentful/auth"
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns unauthorized if invalid key supplied" do
    credentials = ActionController::HttpAuthentication::Token
                    .encode_credentials("an invalid key")
    headers = { "AUTHORIZATION" => credentials }

    post("/api/contentful/auth",
         headers:)

    expect(response).to have_http_status(:unauthorized)
  end
end
