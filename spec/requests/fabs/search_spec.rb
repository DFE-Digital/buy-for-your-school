require "rails_helper"

RSpec.describe "FABS search", type: :request do
  def document
    Capybara.string(response.body)
  end

  it "renders solution, category and page results from one Azure search" do
    results = [
      AzureAiSearch::ContentfulSearcher::SearchResult.new(
        content_type: "solution",
        title: "Commercial catering equipment",
        description: "Buy commercial catering equipment",
        slug: "commercial-catering-equipment",
        primary_category: { "slug" => "catering" },
      ),
      AzureAiSearch::ContentfulSearcher::SearchResult.new(
        content_type: "category",
        title: "Catering",
        description: "Buy catering services",
        slug: "catering",
      ),
      AzureAiSearch::ContentfulSearcher::SearchResult.new(
        content_type: "page",
        title: "Buying guidance",
        description: "Guidance for buying",
        slug: "buying/guidance",
      ),
    ]
    searcher = instance_double(AzureAiSearch::ContentfulSearcher, search: results)
    allow(AzureAiSearch::ContentfulSearcher).to receive(:new).with(query: "catering").and_return(searcher)

    get search_path(query: "catering")

    expect(response).to be_successful
    expect(response.body).to include("<title>Search results - catering - #{I18n.t('service.name')}</title>")
    expect(document).to have_css("h2", text: "3 results for 'catering'")
    expect(document).to have_link("Commercial catering equipment", href: "/categories/catering/commercial-catering-equipment")
    expect(document).to have_link("Catering", href: "/categories/catering")
    expect(document).to have_link("Buying guidance", href: "/buying/guidance")
    expect(AzureAiSearch::ContentfulSearcher).to have_received(:new).with(query: "catering")
  end

  it "escapes HTML in the page title" do
    searcher = instance_double(AzureAiSearch::ContentfulSearcher, search: [])
    allow(AzureAiSearch::ContentfulSearcher).to receive(:new).with(query: "<b>catering</b>").and_return(searcher)

    get search_path(query: "<b>catering</b>")

    expect(response.body).to include("&lt;b&gt;catering&lt;/b&gt;")
    expect(response.body).not_to include("<title>Search results - <b>catering</b>")
  end

  it "renders the no-results state when nothing matches" do
    searcher = instance_double(AzureAiSearch::ContentfulSearcher, search: [])
    allow(AzureAiSearch::ContentfulSearcher).to receive(:new).with(query: "nonexistent").and_return(searcher)

    get search_path(query: "nonexistent")

    expect(response).to be_successful
    expect(document).to have_css("h2", text: "0 results for 'nonexistent'")
    expect(document).to have_css("h3", text: I18n.t("search.no_results.title"))
    expect(response.body).to include(I18n.t("search.no_results.title"))
    expect(document).to have_link(I18n.t("search.no_results.cta"), href: "/")
  end

  it "uses singular wording for one result" do
    result = AzureAiSearch::ContentfulSearcher::SearchResult.new(
      content_type: "solution",
      title: "Commercial catering equipment",
      description: "Buy commercial catering equipment",
      slug: "commercial-catering-equipment",
      primary_category: { "slug" => "catering" },
    )
    searcher = instance_double(AzureAiSearch::ContentfulSearcher, search: [result])
    allow(AzureAiSearch::ContentfulSearcher).to receive(:new).with(query: "catering").and_return(searcher)

    get search_path(query: "catering")

    expect(document).to have_css("h2", text: "1 result for 'catering'")
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
    get search_path(query: (%w[word] * 26).join(" "))

    expect(response.body).to include(I18n.t("search.errors.too_many_words"))
  end
end
