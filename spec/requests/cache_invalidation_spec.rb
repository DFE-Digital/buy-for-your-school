require "rails_helper"

RSpec.describe "Cache invalidation", type: :request do
  it "removes any matching entry ID from the cache" do
    RedisCache.redis.set("contentful:entry:6zeSz4F4YtD66gT5SFpnSB", "a dummy value")

    fake_contentful_webook_payload = {
      "entityId": "6zeSz4F4YtD66gT5SFpnSB",
      "spaceId": "rwl7tyzv9sys",
      "parameters": {
        "text": "Entity version: 62"
      }
    }

    post "/api/contentful/entry_updated",
      params: fake_contentful_webook_payload,
      as: :json

    expect(response).to have_http_status(:ok)
    expect(RedisCache.redis.get("contentful:entry:6zeSz4F4YtD66gT5SFpnSB")).to eq(nil)
  end
end
