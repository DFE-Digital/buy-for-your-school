require "rails_helper"

RSpec.describe "Favicon", type: :request do
  it "returns a not found response without hitting Contentful page lookups" do
    expect(FABS::Page).not_to receive(:find_by_slug!)

    get "/favicon.ico"

    expect(response).to have_http_status(:not_found)
  end
end
