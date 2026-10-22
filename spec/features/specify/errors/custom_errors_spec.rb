RSpec.feature "Custom Errors" do
  context "when the page does not exist (404)" do
    around do |example|
      original_show_exceptions = Rails.application.env_config["action_dispatch.show_exceptions"]
      original_show_detailed_exceptions = Rails.application.env_config["action_dispatch.show_detailed_exceptions"]
      original_consider_all_requests_local = Rails.application.env_config["consider_all_requests_local"]

      Rails.application.env_config["action_dispatch.show_exceptions"] = true
      Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false
      Rails.application.env_config["consider_all_requests_local"] = false

      example.run
    ensure
      Rails.application.env_config["action_dispatch.show_exceptions"] = original_show_exceptions
      Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = original_show_detailed_exceptions
      Rails.application.env_config["consider_all_requests_local"] = original_consider_all_requests_local
    end

    before do
      allow(FABS::Page).to receive(:find_by_slug!).with("foo")
        .and_raise(ContentfulRecordNotFoundError.new("Page not found", slug: "foo"))
    end

    it "shows the expected error message, back link and navigation" do
      visit "/foo"

      expect(find("h1.govuk-heading-xl", text: "Page not found")).to be_present
      expect(find("p.govuk-body", text: "If you entered a web address, check it is correct.")).to be_present
      expect(find("p.govuk-body", text: "If you pasted the web address, check you copied the entire address.")).to be_present
      expect(page).to have_link(
        "ghbs.website@education.gov.uk",
        href: "mailto:ghbs.website@education.gov.uk",
      )

      expect(page).to have_css(".govuk-back-link")
      expect(page).to have_css(".gem-c-layout-super-navigation-header")
    end
  end

  it "the 500 error page shows the expected error message and navigation" do
    visit "/500"

    expect(find("h1.govuk-heading-xl", text: "Sorry, there is a problem with the service")).to be_present
    expect(find("p.govuk-body", text: "Try again later.")).to be_present
    expect(find("p.govuk-body", text: "If you were filling in a request for help, we have not saved your answers. When the service is available, you will have to start again.")).to be_present
    expect(page).to have_link(
      "ghbs.website@education.gov.uk",
      href: "mailto:ghbs.website@education.gov.uk",
    )

    expect(page).to have_css(".govuk-back-link")
    expect(page).to have_css(".gem-c-layout-super-navigation-header")
  end

  it "the 422 error page shows the expected error message and navigation" do
    visit "/422"

    expect(find("h1.govuk-heading-xl", text: "Unacceptable request")).to be_present
    expect(find("p.govuk-body", text: "The request could not be processed.")).to be_present

    expect(page).to have_css(".govuk-back-link")
    expect(page).to have_css(".gem-c-layout-super-navigation-header")
  end
end
