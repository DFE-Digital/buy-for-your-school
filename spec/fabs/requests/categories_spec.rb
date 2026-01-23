require "rails_helper"

RSpec.describe "Categories pages", :vcr, type: :request do
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

  describe "GET /categories/:slug" do
    before do
      get category_path("it")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "displays the category title" do
      expect(response.body).to include("IT")
    end

    it "sets correct HTML title tag" do
      expect(response.body).to include("<title>IT - #{I18n.t('service.name')}</title>")
    end

    it "displays the category description" do
      expect(response.body).to include("Buy IT and ICT equipment and services")
    end

    it "displays solutions in the category" do
      expect(response.body).to include("Everything ICT")
    end

    it "displays related content" do
      expect(response.body).to include("Related content")
      expect(response.body).to have_link("Plan technology for your school")
    end

    it "displays breadcrumbs with Home only" do
      expect(response.body).to have_css("nav.govuk-breadcrumbs")
      expect(response.body).to have_link("Home", href: "/")
    end
  end

  describe "GET /categories/:slug with banner" do
    before do
      get category_path("banking-finance")
    end

    it "displays banner structure" do
      expect(response.body).to have_css(".content-banner")
      expect(response.body).to have_css(".content-banner__title")
    end

    it "displays banner link" do
      expect(response.body).to have_link("Current accounts and savings", href: "/savings-options-for-schools")
    end

    it "displays banner description" do
      expect(response.body).to have_css(".content-banner__description", text: "Access a range of current accounts, savings accounts, and other services designed to increase the interest paid on balances held in the short and long term.")
    end
  end

  describe "GET /categories/:slug with no related content" do
    before do
      get category_path("risk-protection-and-insurance")
    end

    it "does not display related content" do
      expect(response.body).not_to include("Related content")
    end
  end

  describe "GET /categories/:slug with subcategory filters" do
    context "with empty subcategory_slugs parameter" do
      before do
        get category_path("it", subcategory_slugs: [])
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "displays all solutions in the category" do
        expect(response.body).to include("IT Hardware")
        expect(response.body).to include("Everything ICT")
      end
    end

    context "with specific subcategory_slugs parameters" do
      before do
        get category_path("it", subcategory_slugs: %w[software])
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "only displays solutions with matching subcategories" do
        expect(response.body).to include("Corporate software and related products and services")
        expect(response.body).to include("Everything ICT")
        expect(response.body).not_to include("Cyber security services 4")
      end
    end

    context "when form is submitted with selected subcategories" do
      before do
        get category_path("it", subcategory_slugs: %w[computers-and-other-hardware software])
      end

      it "keeps the checkboxes selected after form submission" do
        expect(response.body).to have_css("input[value='software'][checked]")
        expect(response.body).to have_css("input[value='cyber-security']:not([checked])")
      end
    end
  end
end
