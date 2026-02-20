require "rails_helper"

RSpec.describe "Offer Details Page", :vcr, type: :feature do
  describe "GET /offers/:slug" do
    before do
      visit offer_path("energy-for-schools")
    end

    it "returns a successful response" do
      expect(page).to have_http_status(:success)
    end

    it "displays the offer title" do
      expect(page).to have_content("Energy for Schools")
    end
  end

  context "when displaying breadcrumbs" do
    it "displays only home and offer breadcrumbs" do
      visit offer_path("energy-for-schools")
      expect(page).to have_css(".govuk-breadcrumbs__link", count: 2)
      expect(page).to have_link("Home", class: "govuk-breadcrumbs__link")
      expect(page).to have_link("Offers", class: "govuk-breadcrumbs__link")
    end
  end

  context "when displaying call to action button" do
    it "displays the default CTA text when no custom CTA text is provided" do
      visit offer_path("energy-for-schools")
      expect(page).to have_css(".cta")
    end

    it "links to the correct URL for the offer" do
      visit offer_path("energy-for-schools")
      link = find("a.govuk-button[href]", match: :first)
      expect(link[:href]).to eq("https://www.get-help-buying-for-schools.service.gov.uk/energy/before-you-start")
    end
  end
end
