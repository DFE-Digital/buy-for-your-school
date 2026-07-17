require "rails_helper"

RSpec.describe "FABS category pages", type: :request do
  before do
    allow(FABS::Category).to receive(:find_by_slug!).with("it").and_return(category)
    allow(category).to receive(:solutions).and_return(solutions)

    allow(category).to receive(:filtered_solutions) do |subcategory_slugs:, ways_to_buy_slugs:|
      case [subcategory_slugs, ways_to_buy_slugs]
      when [nil, nil], [[], []]
        solutions
      when [%w[software], nil], [%w[software], []]
        [dfe_solution, other_solution]
      when [nil, %w[dps]], [[], %w[dps]]
        [dfe_solution]
      when [%w[software], %w[dps]]
        [dfe_solution]
      else
        solutions
      end
    end
  end

  let(:banner) do
    instance_double(
      Banner,
      title: "Current accounts and savings",
      description: "Access a range of current accounts and savings options.",
      url: "/savings-options-for-schools",
      image: OpenStruct.new(url: "/assets/images/banner.jpg"),
    )
  end

  let(:get_expert_help) do
    instance_double(
      GetExpertHelp,
      title: "Start your request",
      description: "Fill in our short form and get help from our team of buying experts.",
    )
  end

  let(:solutions) { [dfe_solution, other_solution, another_solution] }

  let(:software_subcategory) { OpenStruct.new(slug: "software", title: "Software") }
  let(:hardware_subcategory) { OpenStruct.new(slug: "computers-and-other-hardware", title: "Computers and other hardware") }
  let(:cyber_subcategory) { OpenStruct.new(slug: "cyber-security", title: "Cyber security") }

  let(:subcategories) { [hardware_subcategory, software_subcategory, cyber_subcategory] }
  let(:related_link) { OpenStruct.new(link_text: "Plan technology for your school", url: "/plan-technology") }

  let(:dps_ways_to_buy) do
    OpenStruct.new(
      fields: {
        title: "DPS",
        slug: "dps",
      },
    )
  end

  let(:framework_ways_to_buy) do
    OpenStruct.new(
      fields: {
        title: "Framework",
        slug: "framework",
      },
    )
  end

  let(:dfe_solution) do
    instance_double(
      Solution,
      title: "Everything ICT",
      description: "A DfE-approved ICT route.",
      slug: "everything-ict",
      provider_name: "DfE",
      expiry: nil,
      buying_option_type: "dfe-approved",
      subcategories: [software_subcategory, hardware_subcategory],
      ways_to_buy: dps_ways_to_buy,
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
      subcategories: [software_subcategory],
      ways_to_buy: framework_ways_to_buy,
    )
  end
  let(:another_solution) do
    instance_double(
      Solution,
      title: "Cyber security services 4",
      description: "Cyber route.",
      slug: "cyber-security-services-4",
      provider_name: "Some provider",
      expiry: nil,
      buying_option_type: nil,
      subcategories: [software_subcategory, cyber_subcategory],
      ways_to_buy: framework_ways_to_buy,
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
      get_expert_help:,
    )
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
    expect(document).to have_link("Plan technology for your school", href: "http://localhost:3000/plan-technology")
    expect(document).to have_link("Home", href: "/")
  end

  it "renders the category banner when present" do
    get category_path("it")

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
    get category_path("it"), params: { subcategory_slugs: %w[software] }

    expect(response).to be_successful
    expect(response.body).to include("Everything ICT")
    expect(response.body).to include("Corporate software and related products and services")
    expect(response.body).not_to include("Cyber security services 4")
  end

  it "keeps the selected subcategory values are visible after submission" do
    get category_path("it"), params: { subcategory_slugs: %w[computers-and-other-hardware software] }

    # checkboxes are not visible in the rendered HTML due to accordion behavior, so we check for the presence of the selected filter tags instead
    expect(document).to have_css(".moj-filter__tag", text: "Software")
    expect(document).to have_css(".moj-filter__tag", text: "Computers and other hardware")
    expect(document).to have_no_css(".moj-filter__tag", text: "Cyber security")
  end

  it "shows only matching solutions when ways_to_buy filters are selected" do
    get category_path("it"), params: { ways_to_buy_slugs: %w[dps] }

    expect(response).to be_successful
    expect(response.body).to include("Everything ICT")
    expect(response.body).not_to include("Corporate software and related products and services")
    expect(response.body).not_to include("Cyber security services 4")
  end

  it "keeps the selected ways_to_buy values are visible after submission" do
    get category_path("it"), params: { ways_to_buy_slugs: %w[dps] }

    expect(document).to have_css(".moj-filter__tag", text: "DPS")
    expect(document).to have_no_css(".moj-filter__tag", text: "Framework")
  end
end
