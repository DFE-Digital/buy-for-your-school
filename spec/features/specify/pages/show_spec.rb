require "rails_helper"

RSpec.feature "Showing a Page" do
  # `our_page` so we don't clash with Capybara `page`
  let(:our_page) { create(:page, sidebar:, body:, updated_at: Date.parse("1 January 2022")) }
  let(:updated_at) { "Last updated 1 January 2022" }

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
      visit "/#{our_page.slug}"
      expect(find(".govuk-grid-column-two-thirds h1")).to have_text("hello body")
      expect(find(".govuk-grid-column-one-third h1")).to have_text("hello sidebar")
      expect(find("#last-updated")).to have_text(updated_at)
    end
  end

  context "without a sidebar" do
    let(:sidebar) { nil }
    let(:body) { "# hello body" }

    it "shows the page without a sidebar" do
      visit "/#{our_page.slug}"
      expect(page).not_to have_css("#page-sidebar")
    end
  end
end
