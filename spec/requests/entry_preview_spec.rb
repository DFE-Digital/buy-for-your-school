require "rails_helper"

RSpec.describe "Entry previews", type: :request do
  before { user_is_signed_in }

  context "when PREVIEW_APP is configured to true" do
    around do |example|
      ClimateControl.modify(CONTENTFUL_PREVIEW_APP: "true") do
        example.run
      end
    end

    it "creates a dummy journey and redirects to the question creation flow" do
      entry_id = "123"
      fake_journey = create(:journey)
      allow(Journey).to receive(:create)
        .with(category: anything, user: anything)
        .and_return(fake_journey)

      fake_get_contentful_entry = instance_double(Contentful::Entry)
      allow_any_instance_of(GetEntry).to receive(:call)
        .and_return(fake_get_contentful_entry)

      fake_step = create(:step, :radio)
      allow_any_instance_of(CreateStep).to receive(:call)
        .and_return(fake_step)

      get "/preview/entries/#{entry_id}"

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to("/journeys/#{fake_journey.id}/steps/#{fake_step.id}")
    end
  end

  context "when PREVIEW_APP is configured to false" do
    around do |example|
      ClimateControl.modify(CONTENTFUL_PREVIEW_APP: "false") do
        example.run
      end
    end

    it "does not create a dummy journey and shows not_found" do
      get "/preview/entries/123"

      expect(Journey).not_to receive(:create)
      expect(response).to have_http_status(:not_found)
    end
  end
end
