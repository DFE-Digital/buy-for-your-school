require "rails_helper"

RSpec.feature "Showing a Contentful page" do
  let(:contentful_page) { create(:page, sidebar: sidebar, body: body) }

  before do
    visit "/dashboard"
  end

  context "when visiting a non-existent page slug" do
    let(:sidebar) { nil }
    let(:body) { nil }

    it "shows the not found page" do
      visit "/non-existent-page"
      expect(find("h2.govuk-heading-xl")).to have_text("Page not found")
    end
  end

  context "with a page with a sidebar" do
    let(:sidebar) { "# hello sidebar" }
    let(:body) { "# hello body" }

    it "shows the page with a sidebar" do
      visit "/#{contentful_page.slug}"
      expect(find(".govuk-grid-column-two-thirds h1")).to have_text("hello body")
      expect(find(".govuk-grid-column-one-third h1")).to have_text("hello sidebar")
    end
  end

  context "without a sidebar" do
    let(:sidebar) { nil }
    let(:body) { "# hello body" }

    it "shows the page without a sidebar" do
      visit "/#{contentful_page.slug}"
      expect(find(".md-override h1")).to have_text("hello body")
      expect(page).not_to have_css(".govuk-grid-column-two-thirds")
      expect(page).not_to have_css(".govuk-grid-column-one-third")
    end
  end
end
