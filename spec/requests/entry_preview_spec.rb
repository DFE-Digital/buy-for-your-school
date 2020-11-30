require "rails_helper"

RSpec.describe "Entry previews", type: :request do
  it "creates a dummy journey and redirects to the question creation flow" do
    entry_id = "123"
    fake_journey = create(:journey)
    expect(Journey).to receive(:create)
      .with(category: anything, next_entry_id: entry_id)
      .and_return(fake_journey)

    get "/preview/entries/#{entry_id}"

    expect(response).to have_http_status(:found)
    expect(response).to redirect_to("/journeys/#{fake_journey.id}/questions/new")
  end
end
