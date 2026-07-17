RSpec.feature "Page with breadcrumbs" do
  def contentful_entry(id:, fields:, content_type:)
    double(
      "Contentful::Entry",
      id:,
      fields:,
      content_type: double("Contentful::ContentType", id: content_type),
    )
  end

  let(:parent_page_entry) do
    contentful_entry(
      id: "page-parent",
      content_type: "page",
      fields: {
        title: "Test Page 1",
        description: "Parent page",
        body: "Parent body",
        slug: "test-page-1",
        parent: nil,
        related_content: [],
      },
    )
  end

  let(:our_page_entry) do
    contentful_entry(
      id: "page-child",
      content_type: "page",
      fields: {
        title: "Test Page 2",
        description: "Child page",
        body: "Child body",
        slug: "test-page-2",
        parent: parent_page_entry,
        related_content: [],
      },
    )
  end

  before do
    allow(FABS::Page).to receive(:find_by_slug!).with("test-page-1").and_return(FABS::Page.new(parent_page_entry))
    allow(FABS::Page).to receive(:find_by_slug!).with("test-page-2").and_return(FABS::Page.new(our_page_entry))
  end

  it "shows the breadcrumbs" do
    visit "/test-page-2"
    expect(page).to have_breadcrumbs ["Home", "Test Page 1"]
  end

  it "takes user to the right breadcrumb page" do
    visit "/test-page-2"

    click_link "Test Page 1"
    expect(page).to have_current_path "/test-page-1"
    expect(page).to have_breadcrumbs %w[Home]
  end
end
