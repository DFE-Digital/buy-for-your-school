require "rails_helper"

RSpec.describe "Homepage Offers Section", type: :feature do
  let(:featured_offer) do
    Offer.new(
      OpenStruct.new(
        id: "offer-1",
        fields: {
          title: "Featured offer",
          description: "Featured offer description",
          summary: "Featured offer summary",
          slug: "featured-offer",
          url: "https://example.com/featured-offer",
          call_to_action: nil,
          image: nil,
          featured_on_homepage: true,
          expiry: nil,
          sort_order: 1,
          related_content: [],
        },
      ),
    )
  end
  let(:featured_offer_with_image) do
    Offer.new(
      OpenStruct.new(
        id: "offer-2",
        fields: {
          title: "Featured offer with image",
          description: "Featured offer description",
          summary: "Featured offer summary",
          slug: "featured-offer-with-image",
          url: "https://example.com/featured-offer-with-image",
          call_to_action: nil,
          image: OpenStruct.new(url: "https://example.com/image.jpg"),
          featured_on_homepage: true,
          expiry: nil,
          sort_order: 1,
          related_content: [],
        },
      ),
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
      expect(page).to have_css("h2.govuk-heading-m", text: "Featured")
    end
  end

  context "when there are featured offers" do
    before do
      visit root_path
    end

    it "shows the offers section" do
      expect(page).to have_css("h2.govuk-heading-m", text: "Featured")
      expect(page).to have_css(".offers-grid-container .dfe-card.dfe-card--featured")
    end

    it "shows featured offers with images" do
      allow(Offer).to receive(:featured_offers).and_return([featured_offer_with_image])

      visit root_path

      expect(page).to have_css(".dfe-card--featured img[src='https://example.com/image.jpg'][alt='Featured offer with image']")
    end

    it "shows all featured offers as cards" do
      expect(page).to have_css(".offers-grid-container .dfe-card.dfe-card--featured")
    end
  end
end
