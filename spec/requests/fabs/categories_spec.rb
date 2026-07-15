require "rails_helper"

RSpec.describe "Categories pages", type: :request do
  let(:categories) do
    [
      instance_double(FABS::Category, title: "Banking and finance", description: "Buy financial services", slug: "banking-and-finance"),
      instance_double(FABS::Category, title: "Catalogues", description: "Buy catalogues", slug: "catalogues"),
      instance_double(FABS::Category, title: "Catering", description: "Buy food, drink and catering services", slug: "catering"),
    ]
  end
  let(:featured_offers) { [] }
  let(:energy_banner) { nil }

  describe "GET /" do
    before do
      allow(FABS::Category).to receive(:all).and_return(categories)
      allow(Offer).to receive(:featured_offers).and_return(featured_offers)
      allow(Banner).to receive(:find_by_slug).and_return(energy_banner)
      get root_path
    end

    it "sets default HTML title tag" do
      expect(response.body).to include("<title>#{I18n.t('service.name')}</title>")
    end

    it "includes buying options section heading" do
      expect(response.body).to include("DfE-approved buying options by category")
    end

    it "displays category titles" do
      expected_titles = ["Banking and finance", "Catalogues", "Catering"]

      expected_titles.each do |title|
        expect(response.body).to include(title)
      end
    end

    it "displays category descriptions" do
      expected_descriptions = [
        "Buy financial services",
        "Buy food, drink and catering services",
      ]

      expected_descriptions.each do |description|
        expect(response.body).to include(description)
      end
    end

    it "does not display categories without solutions" do
      expect(response.body).not_to include("category-without-any-solution")
    end

    it "displays new request for help content" do
      expect(response.body).to include("Not sure where to start?")
      expect(response.body).to include("Our buying team can help you choose the right way to buy for your school")
      expect(response.body).to include('href="/procurement-support">Get expert buying help')
    end
  end
end
