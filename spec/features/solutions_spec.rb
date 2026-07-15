require "rails_helper"

RSpec.describe "Solutions pages", type: :feature do
  before do
    I18n.backend.store_translations(:en, date: { formats: { standard: "%-d %B %Y" } })
    allow(FABS::Category).to receive(:find_by_slug!).with(nil).and_return(nil)
    allow_any_instance_of(SolutionsController).to receive(:category_solution_url).and_return("http://www.example.com/solutions/it-hardware")
  end

  let(:related_content) do
    [OpenStruct.new(link_text: "Plan technology for your school", url: "/plan-technology")]
  end

  let(:it_category) { instance_double(FABS::Category, title: "IT", slug: "it") }

  let(:it_hardware_solution) do
    instance_double(
      Solution,
      title: "IT Hardware",
      description: "A full range of IT hardware including new, refurbished, and remanufactured.",
      summary: "## What it offers\n\n## Benefits",
      slug: "it-hardware",
      suffix: nil,
      related_content:,
      provider_name: "Provider Procurement Services",
      expiry: "2025-08-31",
      provider_reference: nil,
      call_to_action: nil,
      url: "https://www.procurementservices.co.uk/our-solutions/frameworks/technology/it-hardware",
      primary_category: it_category,
    )
  end

  let(:software_application_solution) do
    instance_double(
      Solution,
      title: "Software Application Solutions",
      description: "Software applications for public sector organisations.",
      summary: "Software application summary",
      slug: "software-application-solutions",
      suffix: nil,
      related_content: related_content,
      provider_name: "Provider Procurement Services",
      expiry: "2025-08-31",
      provider_reference: nil,
      call_to_action: nil,
      url: "https://example.com/software",
      primary_category: it_category,
    )
  end

  let(:musical_instruments_solution) do
    instance_double(
      Solution,
      title: "Musical Instruments, Equipment and Technology",
      description: "Musical instruments equipment and technology.",
      summary: "Musical instruments summary",
      slug: "musical-instruments-equipment-and-technology",
      suffix: nil,
      related_content: related_content,
      provider_name: "Provider Procurement Services",
      expiry: nil,
      provider_reference: nil,
      call_to_action: nil,
      url: "https://example.com/musical-instruments",
      primary_category: it_category,
    )
  end

  let(:debt_resolution_solution) do
    instance_double(
      Solution,
      title: "Debt Resolution Services",
      description: "Debt resolution services.",
      summary: "Debt resolution summary",
      slug: "debt-resolution-services",
      suffix: nil,
      related_content: related_content,
      provider_name: "Provider Procurement Services",
      expiry: "2025-08-31",
      provider_reference: "what-uu",
      call_to_action: nil,
      url: "https://example.com/debt",
      primary_category: it_category,
    )
  end

  let(:ict_procurement_solution) do
    instance_double(
      Solution,
      title: "ICT Procurement",
      description: "ICT procurement services.",
      summary: "ICT procurement summary",
      slug: "ict-procurement",
      suffix: nil,
      related_content: related_content,
      provider_name: "Provider Procurement Services",
      expiry: "2025-08-31",
      provider_reference: nil,
      call_to_action: "Go to site",
      url: "https://example.com/go-to-site",
      primary_category: it_category,
    )
  end

  before do
    allow(Solution).to receive(:find_by_slug!).with("it-hardware").and_return(it_hardware_solution)
    allow(Solution).to receive(:find_by_slug!).with("software-application-solutions").and_return(software_application_solution)
    allow(Solution).to receive(:find_by_slug!).with("musical-instruments-equipment-and-technology").and_return(musical_instruments_solution)
    allow(Solution).to receive(:find_by_slug!).with("debt-resolution-services").and_return(debt_resolution_solution)
    allow(Solution).to receive(:find_by_slug!).with("ict-procurement").and_return(ict_procurement_solution)
  end

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
      expect(page).to have_content("Related Content")
    end

    it "displays the related content link" do
      expect(page).to have_link("Plan technology for your school")
    end

    it "displays provider and expires when the solution has them" do
      expect(page).to have_content("Provider Procurement Services")
      expect(page).to have_content("Expires 31 August 2025")
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

      expect(uri.host).to eq("get-help-buying-for-schools.education.gov.uk")
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
