require "rails_helper"

RSpec.describe "Homepage Offers Section", :vcr, type: :feature do
  context "when visiting the homepage" do
    before do
      visit root_path
    end

    it "shows the offers section" do
      expect(page).to have_css("h2.govuk-heading-m", text: "DfE featured")
    end
  end

  context "when there are featured offers" do
    before do
      visit root_path
    end

    it "shows the offers section" do
      expect(page).to have_css("h2.govuk-heading-m", text: "DfE featured")
      expect(page).to have_css(".offers-grid-container .dfe-card.dfe-card--featured")
    end

    it "shows all featured offers as cards" do
      expect(page).to have_css(".offers-grid-container .dfe-card.dfe-card--featured")
    end
  end
end
