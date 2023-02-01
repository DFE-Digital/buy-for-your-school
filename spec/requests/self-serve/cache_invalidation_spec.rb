require "rails_helper"

RSpec.describe "Cache invalidation", type: :request do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_WEBHOOK_API_KEY: "an API key",
    ) do
      example.run
    end
  end

  # TODO: remove this and all the string interpolation
  let(:prefix) { Cache::ENTRY_CACHE_KEY_PREFIX }

  it "removes any matching entry ID from the cache" do
    RedisCache.redis.set("#{prefix}:6zeSz4F4YtD66gT5SFpnSB", "a dummy value")

    fake_contentful_webook_payload = {
      entityId: "6zeSz4F4YtD66gT5SFpnSB",
      spaceId: "rwl7tyzv9sys",
      parameters: {
        text: "Entity version: 62",
      },
    }

    credentials = ActionController::HttpAuthentication::Token
      .encode_credentials(ENV["CONTENTFUL_WEBHOOK_API_KEY"])
    headers = { "AUTHORIZATION" => credentials }

    post "/api/contentful/entry_updated",
         params: fake_contentful_webook_payload,
         headers:,
         as: :json

    expect(response).to have_http_status(:ok)
    expect(RedisCache.redis.get("#{prefix}:6zeSz4F4YtD66gT5SFpnSB")).to eq(nil)
  end

  it "logs information of the event in Rollbar for debugging" do
    fake_contentful_webook_payload = {
      entityId: "6zeSz4F4YtD66gT5SFpnSB",
      spaceId: "rwl7tyzv9sys",
      parameters: {
        text: "Entity version: 62",
      },
    }

    credentials = ActionController::HttpAuthentication::Token
      .encode_credentials(ENV["CONTENTFUL_WEBHOOK_API_KEY"])
    headers = { "AUTHORIZATION" => credentials }

    expect(Rollbar).to receive(:info)
      .with(
        "Accepted request to cache bust Contentful Entry",
        cache_key: "#{prefix}:6zeSz4F4YtD66gT5SFpnSB",
      ).and_call_original

    post "/api/contentful/entry_updated",
         params: fake_contentful_webook_payload,
         headers:,
         as: :json
  end

  context "when no basic auth was provided" do
    it "does not delete anything from the cache and returns 401" do
      RedisCache.redis.set("#{prefix}:6zeSz4F4YtD66gT5SFpnSB", "a dummy value")

      fake_contentful_webook_payload = {
        entityId: "6zeSz4F4YtD66gT5SFpnSB",
        spaceId: "rwl7tyzv9sys",
        parameters: {
          text: "Entity version: 62",
        },
      }

      credentials = ActionController::HttpAuthentication::Token
        .encode_credentials("an invalid token!")
      headers = { "AUTHORIZATION" => credentials }

      post "/api/contentful/entry_updated",
           params: fake_contentful_webook_payload,
           headers:,
           as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(RedisCache.redis.get("#{prefix}:6zeSz4F4YtD66gT5SFpnSB")).to eq("a dummy value")
    end
  end
end
