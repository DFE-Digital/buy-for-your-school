RSpec.feature "Custom Errors" do
  context "when the page does not exist (404)" do
    before do
      Rails.application.env_config["action_dispatch.show_exceptions"] = true
      Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false
      Rails.application.env_config["consider_all_requests_local"] = false
    end

    after do
      Rails.application.env_config["action_dispatch.show_exceptions"] = false
      Rails.application.env_config["consider_all_requests_local"] = true
    end

    it "shows the expected error message" do
      visit "/foo"
      # errors.not_found.page_title
      expect(find("h2.govuk-heading-xl")).to have_text "Page not found"
      # errors.not_found.page_body
      expect(all("p.govuk-body").first).to have_text "Page not found. If you typed the web address, check it is correct. If you pasted the web address, check you copied the entire address."
    end
  end

  it "the 500 error page shows the expected error message" do
    visit "/500"
    # errors.internal_server_error.page_title
    expect(find("h2.govuk-heading-xl")).to have_text "Internal server error"
    # errors.internal_server_error.page_body
    expect(all("p.govuk-body").first).to have_text "Sorry, there is a problem with the service. Please try again later."
  end

  it "the 422 error page shows the expected error message" do
    visit "/422"
    # errors.unacceptable.page_title
    expect(find("h2.govuk-heading-xl")).to have_text "Unacceptable request"
    # errors.unacceptable.page_body
    expect(all("p.govuk-body").first).to have_text "There was a problem with your request."
  end
end
