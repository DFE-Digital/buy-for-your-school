require "rails_helper"

RSpec.describe "FABS category pages", type: :request do
  before { Flipper.enable(:ghbs_public_frontend) }

  let(:banner) do
    instance_double(
      Banner,
      title: "Current accounts and savings",
      description: "Access a range of current accounts and savings options.",
      url: "/savings-options-for-schools",
    )
  end
  let(:software_subcategory) { OpenStruct.new(slug: "software", title: "Software") }
  let(:hardware_subcategory) { OpenStruct.new(slug: "computers-and-other-hardware", title: "Computers and other hardware") }
  let(:cyber_subcategory) { OpenStruct.new(slug: "cyber-security", title: "Cyber security") }
  let(:subcategories) { [hardware_subcategory, software_subcategory, cyber_subcategory] }
  let(:related_link) { OpenStruct.new(link_text: "Plan technology for your school", url: "/plan-technology") }
  let(:dfe_solution) do
    instance_double(
      Solution,
      title: "Everything ICT",
      description: "A DfE-approved ICT route.",
      slug: "everything-ict",
      provider_name: "DfE",
      expiry: nil,
      buying_option_type: "dfe-approved",
    )
  end
  let(:other_solution) do
    instance_double(
      Solution,
      title: "Corporate software and related products and services",
      description: "Software buying route.",
      slug: "software-route",
      provider_name: "Crown Commercial Service",
      expiry: nil,
      buying_option_type: nil,
    )
  end
  let(:filtered_solution) do
    instance_double(
      Solution,
      title: "Cyber security services 4",
      description: "Cyber route.",
      slug: "cyber-security-services-4",
      provider_name: "Some provider",
      expiry: nil,
      buying_option_type: nil,
    )
  end
  let(:category) do
    instance_double(
      FABS::Category,
      title: "IT",
      description: "Buy IT and ICT equipment and services",
      slug: "it",
      banner:,
      subcategories:,
      related_content: [related_link],
    )
  end

  before do
    allow(FABS::Category).to receive(:find_by_slug!).with("it").and_return(category)
    allow(category).to receive(:filtered_solutions) do |subcategory_slugs:|
      case subcategory_slugs
      when nil, []
        [dfe_solution, other_solution, filtered_solution]
      when ["software"]
        [dfe_solution, other_solution]
      else
        [dfe_solution, other_solution]
      end
    end
  end

  def document
    Capybara.string(response.body)
  end

  it "renders the category page with title, description, solutions, related content, and breadcrumbs" do
    get category_path("it")

    expect(response).to be_successful
    expect(response.body).to include("<title>IT - #{I18n.t('service.name')}</title>")
    expect(response.body).to include("IT")
    expect(response.body).to include("Buy IT and ICT equipment and services")
    expect(response.body).to include("Everything ICT")
    expect(response.body).to include("Related Content")
    expect(document).to have_link("Plan technology for your school", href: "#")
    expect(document).to have_link("Home", href: "/")
  end

  it "renders the category banner when present" do
    get category_path("it")

    expect(document).to have_css(".content-banner")
    expect(document).to have_link("Current accounts and savings", href: "/savings-options-for-schools")
    expect(response.body).to include("Access a range of current accounts and savings options.")
  end

  it "omits the related content section when no related content exists" do
    allow(category).to receive(:related_content).and_return([])

    get category_path("it")

    expect(response.body).not_to include("Related Content")
  end

  it "shows all solutions when the filter is submitted with no subcategories" do
    get category_path("it"), params: { subcategory_slugs: [] }

    expect(response).to be_successful
    expect(response.body).to include("Everything ICT")
    expect(response.body).to include("Corporate software and related products and services")
    expect(response.body).to include("Cyber security services 4")
  end

  it "shows only matching solutions when subcategory filters are selected" do
    get category_path("it"), params: { subcategory_slugs: ["software"] }

    expect(response).to be_successful
    expect(response.body).to include("Everything ICT")
    expect(response.body).to include("Corporate software and related products and services")
    expect(response.body).not_to include("Cyber security services 4")
  end

  it "keeps the selected subcategory checkboxes checked after submission" do
    get category_path("it"), params: { subcategory_slugs: %w[computers-and-other-hardware software] }

    expect(document).to have_css("input[value='software'][checked]")
    expect(document).to have_css("input[value='computers-and-other-hardware'][checked]")
    expect(document).to have_no_css("input[value='cyber-security'][checked]")
  end
end
