require "rails_helper"

RSpec.describe "Solutions", :vcr, type: :request do
  describe "GET /solutions/:slug" do
    before do
      get solution_path("it-hardware")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "sets correct HTML title tag" do
      expect(response.body).to include("<title>IT Hardware - #{I18n.t('service.name')}</title>")
    end

    it "set correct breadcrumb" do
      expect(response.body).to include('<a class="govuk-breadcrumbs__link" href="/">Home</a>')
      expect(response.body).to include('<a class="govuk-breadcrumbs__link" href="/categories/it">IT</a>')
    end
  end

  describe "GET /solutions" do
    before do
      get solutions_path
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "sets correct HTML title tag" do
      expect(response.body).to include("<title>#{I18n.t('solutions.index.all_buying_options_title')} - #{I18n.t('service.name')}</title>")
    end

    it "set the correct solution url" do
      expect(response.body).to include('<a class="govuk-link chevron-card__link" href="/categories/banking-finance/audit-and-financial-services">Audit and financial services</a>')
    end
  end
end
