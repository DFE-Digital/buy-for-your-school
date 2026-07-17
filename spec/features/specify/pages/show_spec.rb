require "rails_helper"

RSpec.feature "Showing a Page" do
  # `our_page` so we don't clash with Capybara `page`
  let(:related_content) { [] }
  let(:our_page) do
    OpenStruct.new(
      title: "Test page",
      description: "Test page description",
      body:,
      related_content:,
      parent: nil,
      slug: "test-page",
    )
  end

  context "when visiting a non-existent page slug" do
    let(:sidebar) { nil }
    let(:body) { nil }

    before do
      allow(FABS::Page).to receive(:find_by_slug!).with("non-existent-page")
        .and_raise(ContentfulRecordNotFoundError.new("Page not found", slug: "non-existent-page"))
    end

    it "shows the not found page" do
      visit "/non-existent-page"
      expect(find("h1.govuk-heading-xl")).to have_text("Page not found")
    end
  end

  context "with a page with related content" do
    let(:related_content) do
      [OpenStruct.new(link_text: "Helpful link", url: "/helpful-link")]
    end
    let(:body) { "# hello body" }

    before do
      allow(FABS::Page).to receive(:find_by_slug!).with("test-page").and_return(our_page)
    end

    it "shows the page with related content" do
      visit "/test-page"
      expect(page).to have_text("hello body")
      expect(page).to have_link("Helpful link", href: "http://localhost:3000/helpful-link")
    end
  end

  context "without a sidebar" do
    let(:body) { "# hello body" }

    before do
      allow(FABS::Page).to receive(:find_by_slug!).with("test-page").and_return(our_page)
    end

    it "shows the page without a sidebar" do
      visit "/test-page"
      expect(page).not_to have_css("#page-sidebar")
    end
  end
end
