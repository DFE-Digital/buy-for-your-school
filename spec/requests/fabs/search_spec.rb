require "rails_helper"

RSpec.describe "FABS search", type: :request do
  before do
    Flipper.enable(:ghbs_public_frontend)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("USE_OPENSEARCH", "false").and_return("false")
  end

  let(:category) { instance_double(FABS::Category, title: "Catering", description: "Buy catering services", slug: "catering", to_param: "catering") }
  let(:solution) do
    instance_double(
      Solution,
      title: "Commercial catering equipment",
      description: "Buy commercial catering equipment",
      slug: "commercial-catering-equipment",
      primary_category: category,
    )
  end

  def document
    Capybara.string(response.body)
  end

  it "renders matching solutions and categories for a valid query" do
    allow(Solution).to receive(:search).with(query: "catering").and_return([solution])
    allow(FABS::Category).to receive(:search).with(query: "catering").and_return([category])

    get search_path(query: "catering")

    expect(response).to be_successful
    expect(response.body).to include("<title>Search results - catering - #{I18n.t('service.name')}</title>")
    expect(response.body).to include("Commercial catering equipment")
    expect(response.body).to include("Catering")
  end

  it "escapes HTML in the page title" do
    allow(Solution).to receive(:search).with(query: "<b>catering</b>").and_return([])
    allow(FABS::Category).to receive(:search).with(query: "<b>catering</b>").and_return([])

    get search_path(query: "<b>catering</b>")

    expect(response.body).to include("&lt;b&gt;catering&lt;/b&gt;")
    expect(response.body).not_to include("<title>Search results - <b>catering</b>")
  end

  it "renders the no-results state when nothing matches" do
    allow(Solution).to receive(:search).with(query: "nonexistent").and_return([])
    allow(FABS::Category).to receive(:search).with(query: "nonexistent").and_return([])

    get search_path(query: "nonexistent")

    expect(response).to be_successful
    expect(response.body).to include(I18n.t("search.no_results.title"))
    expect(document).to have_link(I18n.t("search.no_results.cta"), href: "/")
  end

  it "shows the empty validation error for a blank query" do
    get search_path(query: "")

    expect(response).to be_successful
    expect(response.body).to include(I18n.t("search.errors.empty"))
  end

  it "shows the empty validation error when query is nil" do
    get search_path

    expect(response).to be_successful
    expect(response.body).to include(I18n.t("search.errors.empty"))
  end

  it "shows the too_long validation error" do
    get search_path(query: "a" * 151)

    expect(response.body).to include(I18n.t("search.errors.too_long"))
  end

  it "shows the too_many_words validation error" do
    get search_path(query: (["word"] * 26).join(" "))

    expect(response.body).to include(I18n.t("search.errors.too_many_words"))
  end
end
