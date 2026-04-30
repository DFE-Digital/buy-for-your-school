require "rails_helper"

RSpec.describe "FABS pages", type: :request do
  before do
    Flipper.enable(:ghbs_public_frontend)
    allow(Page).to receive(:find_by).and_return(nil)
  end

  def document
    Capybara.string(response.body)
  end

  def contentful_entry(id:, fields:, content_type:)
    double(
      "Contentful::Entry",
      id:,
      fields:,
      content_type: double("Contentful::ContentType", id: content_type),
    )
  end

  def related_content_entry(id:, link_text:, url:)
    OpenStruct.new(id:, fields: { link_text:, url: })
  end

  let(:category_entry) do
    contentful_entry(
      id: "category-1",
      content_type: "category",
      fields: { title: "Banking and finance", description: "Category description", slug: "banking-finance" },
    )
  end
  let(:parent_page_entry) do
    contentful_entry(
      id: "page-parent",
      content_type: "page",
      fields: {
        title: "Current accounts and savings",
        description: "Parent page",
        body: "Parent body",
        slug: "current-account-and-savings",
        parent: category_entry,
        related_content: [],
      },
    )
  end
  let(:page_entry) do
    contentful_entry(
      id: "page-child",
      content_type: "page",
      fields: {
        title: "Unit Trust Bank",
        description: "Child page description",
        body: "Child body",
        slug: "unit-trust-bank",
        parent: parent_page_entry,
        related_content: [
          related_content_entry(id: "rel-1", link_text: "Framework agreements", url: "/framework-agreements"),
        ],
      },
    )
  end

  it "renders a FABS page with title, related content, and nested breadcrumbs" do
    allow(FABS::Page).to receive(:find_by_slug!).with("unit-trust-bank").and_return(FABS::Page.new(page_entry))

    get page_path("unit-trust-bank")

    expect(response).to be_successful
    expect(response.body).to include("<title>Unit Trust Bank - #{I18n.t('service.name')}</title>")
    expect(response.body).to include("Unit Trust Bank")
    expect(response.body).to include("Child page description")
    expect(response.body).to include("Related Content")
    expect(document).to have_link("Home", href: "/")
    expect(document).to have_link("Banking and finance", href: "/categories/banking-finance")
    expect(document).to have_link("Current accounts and savings", href: "/current-account-and-savings")
    expect(document).to have_link("Framework agreements", href: "#")
  end

  it "omits related content when the page has none" do
    no_related_content_entry = contentful_entry(
      id: "page-no-related",
      content_type: "page",
      fields: {
        title: "Dynamic purchasing systems",
        description: "No links",
        body: "Body",
        slug: "dynamic-purchasing-systems",
        parent: category_entry,
        related_content: [],
      },
    )
    allow(FABS::Page).to receive(:find_by_slug!).with("dynamic-purchasing-systems").and_return(FABS::Page.new(no_related_content_entry))

    get page_path("dynamic-purchasing-systems")

    expect(response).to be_successful
    expect(response.body).not_to include("Related Content")
  end

  it "redirects to /404 when the FABS page does not exist" do
    allow(FABS::Page).to receive(:find_by_slug!).with("missing-page")
      .and_raise(ContentfulRecordNotFoundError.new("Page not found", slug: "missing-page"))

    get page_path("missing-page")

    expect(response).to redirect_to("/404")
  end
end
