RSpec.feature "To alert users to the current stage of development" do
  before do
    visit "/"
  end

  it "renders a beta phase banner" do
    # banner.beta.tag
    expect(find("strong.govuk-phase-banner__content__tag")).to have_content "beta"
    # banner.beta.message
    expect(find("span.govuk-phase-banner__text")).to have_text "This is a new service – your feedback will help us to improve it."
    expect(find("span.govuk-phase-banner__text")).to have_link "feedback", href: "/feedback/new", class: "govuk-link"
  end
end
