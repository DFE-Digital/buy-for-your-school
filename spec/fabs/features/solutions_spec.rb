require "rails_helper"

RSpec.describe "Solutions pages", :vcr, type: :feature do
  describe "GET /solutions/:slug" do
    before do
      visit solution_path("it-hardware")
    end

    it "returns a successful response" do
      expect(page).to have_http_status(:success)
    end

    it "displays the solution title" do
      expect(page).to have_content("IT Hardware")
    end

    it "displays the solution description" do
      expect(page).to have_content("A full range of IT hardware including new, refurbished, and remanufactured.")
    end

    it "displays key solution detail sections" do
      expect(page).to have_content("What it offers")
      expect(page).to have_content("Benefits")
    end

    it "displays related content section" do
      expect(page).to have_content("Related content")
    end

    it "displays the related content link" do
      expect(page).to have_link("Plan technology for your school")
    end

    it "displays provider and expires when the solution has them" do
      expect(page).to have_content("Provider: Procurement Services")
      expect(page).to have_content("Expires: 31 August 2025")
    end

    it "When the solution has no expires" do
      visit solution_path("musical-instruments-equipment-and-technology")
      expect(page).to have_no_content("Expires:")
    end

    it "When the solution has no provider reference" do
      expect(page).to have_no_content("Provider Reference:")
    end

    it "display provider reference when provider reference is set" do
      visit solution_path("debt-resolution-services")
      expect(page).to have_content("what-uu")
    end
  end

  context "when displaying call to action button" do
    it "displays the default CTA text when no custom CTA is provided" do
      visit solution_path("it-hardware")
      expect(page).to have_link("Visit the provider’s website", class: "govuk-button")
    end

    it "displays the custom CTA text when provided" do
      visit solution_path("ict-procurement")
      expect(page).to have_link("Go to site", class: "govuk-button")
    end

    it "includes the usability survey URL with service and return_url params", skip: "Survey link temporarily removed to allow time to create an improved design solution" do
      visit solution_path("it-hardware")
      link = find("a.govuk-button[href]", match: :first)
      survey_url = link["href"]
      uri = URI.parse(survey_url)

      expect(uri.host).to eq("www.get-help-buying-for-schools.service.gov.uk")
      expect(survey_url).to include("service=find_a_buying_solution")
      expect(survey_url).to match(/return_url=[^&]+/)
    end

    it "sets the CTA button href to the solution url" do
      visit solution_path("it-hardware")
      link = find("a.govuk-button[href]", match: :first)
      expect(link[:href]).to eq("https://www.procurementservices.co.uk/our-solutions/frameworks/technology/it-hardware")
    end
  end

  context "when displaying breadcrumbs" do
    it "display only home breadcrumb with no primary category" do
      visit solution_path("it-hardware")
      expect(page).to have_link("Home", class: "govuk-breadcrumbs__link")
      expect(page).to have_css(".govuk-breadcrumbs__link", count: 2)
    end

    it "display primary category" do
      visit solution_path("software-application-solutions")
      expect(page).to have_css(".govuk-breadcrumbs__link", count: 2)
      expect(page).to have_link("Home", class: "govuk-breadcrumbs__link")
      expect(page).to have_link("IT", class: "govuk-breadcrumbs__link")
    end
  end
end
