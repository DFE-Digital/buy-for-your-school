require "rails_helper"

RSpec.describe "Pages", :vcr, type: :request do
  describe "GET /pages/:slug" do
    before do
      get page_path("dynamic-purchasing-systems")
    end

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "displays the page title" do
      expect(response.body).to include("Dynamic purchasing systems")
    end

    it "sets correct HTML title tag" do
      expect(response.body).to include("<title>Dynamic purchasing systems - Get help buying for schools</title>")
    end

    it "displays related content section" do
      expect(response.body).to include("Related content")
      expect(response.body).to match(%r{<a[^>]*>Framework agreements</a>})
      expect(response.body).to match(%r{<a[^>]*>Find a DFE-approved buying solution</a>})
    end

    it "displays breadcrumbs with Home and parent category" do
      expect(response.body).to have_css("nav.govuk-breadcrumbs")
      expect(response.body).to have_link("Home", href: "/")
    end
  end

  describe "GET /pages/:slug with parent hierarchy" do
    before do
      get page_path("current-account-and-savings")
    end

    it "displays breadcrumbs with Home and parent category" do
      expect(response.body).to have_css("nav.govuk-breadcrumbs")
      expect(response.body).to have_link("Home", href: "/")
      expect(response.body).to have_link("Banking and finance", href: "/categories/banking-finance")
    end
  end

  describe "GET /pages/:slug with nested parent hierarchy" do
    before do
      get page_path("unit-trust-bank")
    end

    it "displays breadcrumbs with Home, category and parent page" do
      expect(response.body).to have_css("nav.govuk-breadcrumbs")
      expect(response.body).to have_link("Home", href: "/")
      expect(response.body).to have_link("Banking and finance", href: "/categories/banking-finance")
      expect(response.body).to have_link("Current accounts and Savings", href: "/current-account-and-savings")
    end
  end

  context "when page has no related content" do
    before do
      get page_path("cookies")
    end

    it "does not display related content section" do
      expect(response.body).not_to include("Related content")
    end
  end
end
