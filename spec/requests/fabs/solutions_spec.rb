require "rails_helper"

RSpec.describe "FABS solutions", type: :request do
  before do
    Flipper.enable(:ghbs_public_frontend)
    I18n.backend.store_translations(:en, date: { formats: { standard: "%-d %B %Y" } })
  end

  let(:primary_category) do
    instance_double(FABS::Category, title: "Banking and finance", slug: "banking-finance", description: "Banking category")
  end
  let(:solution) do
    instance_double(
      Solution,
      title: "Audit and financial services",
      description: "Buy audit and financial services.",
      summary: "Service summary",
      slug: "audit-and-financial-services",
      categories: [primary_category],
      primary_category:,
      suffix: nil,
      related_content: [OpenStruct.new(link_text: "Framework agreements", url: "/framework-agreements")],
      provider_name: "Provider Ltd",
      expiry: "2026-12-31",
      provider_reference: "RM1234",
      call_to_action: nil,
      url: "https://example.com/apply",
    )
  end

  def document
    Capybara.string(response.body)
  end

  describe "GET /solutions" do
    before do
      allow(Solution).to receive(:all).and_return([solution])
    end

    it "renders the index page and links solutions to category-scoped URLs" do
      get solutions_path

      expect(response).to be_successful
      expect(response.body).to include("<title>#{I18n.t('solutions.index.all_buying_options_title')} - #{I18n.t('service.name')}</title>")
      expect(document).to have_link("Audit and financial services", href: "/categories/banking-finance/audit-and-financial-services")
      expect(response.body).to include("Buy audit and financial services.")
    end
  end

  describe "GET /categories/:category_slug/:slug" do
    before do
      allow(Solution).to receive(:find_by_slug!).with("audit-and-financial-services").and_return(solution)
      allow(FABS::Category).to receive(:find_by_slug!).with("banking-finance").and_return(primary_category)
    end

    it "renders the show page with canonical URL, breadcrumbs, details, related content, and default CTA text" do
      get category_solution_path("banking-finance", "audit-and-financial-services")

      expect(response).to be_successful
      expect(response.body).to include("<title>Audit and financial services - #{I18n.t('service.name')}</title>")
      expect(response.body).to include('<link href="http://www.example.com/categories/banking-finance/audit-and-financial-services" rel="canonical"')
      expect(document).to have_link("Home", href: "/")
      expect(document).to have_link("Banking and finance", href: "/categories/banking-finance")
      expect(response.body).to include("Audit and financial services")
      expect(response.body).to include("Service summary")
      expect(response.body).to include("Provider Ltd")
      expect(response.body).to include("31 December 2026")
      expect(response.body).to include("RM1234")
      expect(response.body).to include("Related Content")
      expect(document).to have_link("Framework agreements", href: "#")
      expect(document).to have_link(I18n.t("solutions.show.cta", title: "Audit and financial services"), href: "https://example.com/apply")
    end

    it "omits blank expiry and provider reference and uses custom CTA text when present" do
      allow(solution).to receive_messages(expiry: nil, provider_reference: nil, call_to_action: "Apply now")

      get category_solution_path("banking-finance", "audit-and-financial-services")

      expect(response.body).not_to include("31 December 2026")
      expect(response.body).not_to include("RM1234")
      expect(document).to have_link("Apply now", href: "https://example.com/apply")
    end
  end
end
