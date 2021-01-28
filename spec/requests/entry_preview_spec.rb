require "rails_helper"

RSpec.describe "Entry previews", type: :request do
  it "creates a dummy journey and redirects to the question creation flow" do
    entry_id = "123"
    fake_journey = create(:journey)
    expect(Journey).to receive(:create)
      .with(category: anything, liquid_template: anything)
      .and_return(fake_journey)

    fake_get_contentful_entry = instance_double(Contentful::Entry)
    allow_any_instance_of(GetEntry).to receive(:call)
      .and_return(fake_get_contentful_entry)

    fake_step = create(:step, :radio)
    allow_any_instance_of(CreateJourneyStep).to receive(:call)
      .and_return(fake_step)

    get "/preview/entries/#{entry_id}"

    expect(response).to have_http_status(:found)
    expect(response).to redirect_to("/journeys/#{fake_journey.id}/steps/#{fake_step.id}")
  end
end
