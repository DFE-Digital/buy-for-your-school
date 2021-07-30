require "rails_helper"

RSpec.describe "Webhook upserts category", type: :request do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_WEBHOOK_API_KEY: "an API key",
      ) do
      example.run
    end
  end

  it "creates a new category" do
    # TODO: create new cat from params
  end
  
  it "updates an existing category" do
    # TODO: update a new cat from params
  end
end
