require "rails_helper"

describe "Static Pages" do
  context "when a static page does not exist" do
    it "renders the 404 page" do
      get "/pages/this-should-not-exist"
      expect(response.body).to include("Page not found")
    end
  end
end
