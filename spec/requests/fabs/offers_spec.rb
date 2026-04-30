require "rails_helper"

RSpec.describe "FABS offers", type: :request do
  before do
    Flipper.enable(:ghbs_public_frontend)
    I18n.backend.store_translations(:en, date: { formats: { standard: "%-d %B %Y" } })
  end

  let(:offer) do
    instance_double(
      Offer,
      title: "Energy for Schools",
      description: "Get help buying energy.",
      summary: "Offer summary",
      slug: "energy-for-schools",
      expiry: "2026-08-31",
      call_to_action: nil,
      url: "https://www.get-help-buying-for-schools.service.gov.uk/energy/before-you-start",
      related_content: [],
    )
  end

  def document
    Capybara.string(response.body)
  end

  describe "GET /offers" do
    before do
      allow(Offer).to receive(:all).and_return([offer])
    end

    it "renders the offers index" do
      get offers_path

      expect(response).to be_successful
      expect(response.body).to include("<title>#{I18n.t('offers.index.title')} - #{I18n.t('service.name')}</title>")
      expect(response.body).to include("Energy for Schools")
      expect(response.body).to include("Get help buying energy.")
      expect(response.body).to include("31 August 2026")
    end
  end

  describe "GET /offers/:slug" do
    before do
      allow(Offer).to receive(:find_by_slug!).with("energy-for-schools").and_return(offer)
    end

    it "renders the offer page with breadcrumbs and default CTA" do
      get offer_path("energy-for-schools")

      expect(response).to be_successful
      expect(response.body).to include("Energy for Schools")
      expect(document).to have_link("Home", href: "/")
      expect(document).to have_link("Offers", href: "/offers")
      expect(document).to have_link(I18n.t("offers.show.cta", title: "Energy for Schools"), href: "https://www.get-help-buying-for-schools.service.gov.uk/energy/before-you-start")
    end
  end
end
