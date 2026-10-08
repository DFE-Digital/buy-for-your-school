require "rails_helper"

RSpec.describe "Favicon", type: :request do
  it "does not hit Contentful page lookups" do
    expect(FABS::Page).not_to receive(:find_by_slug!)
    expect(RedirectMatcher).not_to receive(:call)

    expect { get "/favicon.ico" }.to raise_error(ActionController::RoutingError)
  end
end
