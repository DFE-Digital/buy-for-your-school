require "rails_helper"

RSpec.describe "Entry previews", type: :request do
  it "creates a dummy plan and redirects to the question creation flow" do
    entry_id = "123"
    fake_plan = create(:plan)
    expect(Plan).to receive(:create)
      .with(category: anything, next_entry_id: entry_id)
      .and_return(fake_plan)

    get "/preview/entries/#{entry_id}"

    expect(response).to have_http_status(:found)
    expect(response).to redirect_to("/plans/#{fake_plan.id}/questions/new")
  end
end
