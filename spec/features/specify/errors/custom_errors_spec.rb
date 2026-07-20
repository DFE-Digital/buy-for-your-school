RSpec.feature "Custom Errors" do
  context "when the page does not exist (404)" do
    before do
      Rails.application.env_config["action_dispatch.show_exceptions"] = true
      Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false
      Rails.application.env_config["consider_all_requests_local"] = false
      allow(FABS::Page).to receive(:find_by_slug!).with("foo")
        .and_raise(ContentfulRecordNotFoundError.new("Page not found", slug: "foo"))
    end

    after do
      Rails.application.env_config["action_dispatch.show_exceptions"] = false
      Rails.application.env_config["consider_all_requests_local"] = true
    end

    it "shows the expected error message" do
      visit "/foo"
      expect(find("h1.govuk-heading-xl", text: "Page not found")).to be_present
      expect(find("p.govuk-body", text: "If you entered a web address, check it is correct.")).to be_present
      expect(find("p.govuk-body", text: "If you pasted the web address, check you copied the entire address.")).to be_present
    end
  end

  it "the 500 error page shows the expected error message" do
    visit "/500"
    expect(find("h1.govuk-heading-xl", text: "Sorry, there is a problem with the service")).to be_present
    expect(find("p.govuk-body", text: "Try again later.")).to be_present
  end

  it "the 422 error page shows the expected error message" do
    visit "/422"
    expect(find("h1.govuk-heading-xl", text: "Unacceptable request")).to be_present
    expect(find("p.govuk-body", text: "There was a problem with your request.")).to be_present
  end
end
