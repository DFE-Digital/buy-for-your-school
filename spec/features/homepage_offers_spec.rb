require "rails_helper"

RSpec.describe "Homepage Offers Section", type: :feature do
  let(:featured_offer) do
    instance_double(
      Offer,
      title: "Featured offer",
      description: "Featured offer description",
      url: "https://example.com/featured-offer",
      sort_order: 1,
    )
  end

  before do
    allow(FABS::Category).to receive(:all).and_return([])
    allow(Offer).to receive(:featured_offers).and_return([featured_offer])
    allow(Banner).to receive(:find_by_slug).and_return(nil)
  end

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
