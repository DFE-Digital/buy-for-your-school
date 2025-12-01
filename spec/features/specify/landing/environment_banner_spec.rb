RSpec.feature "To alert users to the current stage of development" do
  before do
    visit "/cms"
  end

  it "renders a beta phase banner with a link to the customer satisfaction survey" do
    # banner.beta.tag
    expect(find("strong.govuk-phase-banner__content__tag")).to have_content "Beta"
    # banner.beta.message
    within("span.govuk-phase-banner__text") do
      expect(page).to have_text "This is a new service – your feedback opens in new tab will help us to improve it"
      expect(page).to have_css(".govuk-visually-hidden", text: "opens in new tab")
      expect(page).to have_link "feedback", href: new_customer_satisfaction_survey_path(source: "banner_link", service: "create_a_spec"), class: "govuk-link"
    end
  end
end
