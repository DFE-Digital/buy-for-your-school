RSpec.describe "Webhook upserts category", type: :request do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_WEBHOOK_API_KEY: "an API key",
      ) do
      example.run
    end
  end

  let!(:fake_contentful_webook_payload) do
    {
      entityId: "6zeSz4F4YtD66gT5SFpnSB",
      spaceId: "rwl7tyzv9sys",
      parameters: {
        text: "Entity version: 62",
      },
    }
  end

  it "creates a new category" do
    # TODO: create new cat from params
  end
  
  it "updates an existing category" do
    # TODO: update a new cat from params
  end
end
