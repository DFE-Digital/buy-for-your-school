require "rails_helper"

RSpec.describe "Categories pages", :vcr, type: :request do
  before { Flipper.enable(:ghbs_public_frontend) }

  describe "GET /" do
    before do
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
  end
end
