RSpec.feature "To alert users to the current stage of development" do
  before do
    visit "/"
  end

  it "renders a beta phase banner" do
    # banner.beta.tag
    expect(find("strong.govuk-phase-banner__content__tag")).to have_content "beta"
    # banner.beta.message
    expect(find("span.govuk-phase-banner__text")).to have_text "This is a new service – your feedback will help us to improve it."
    expect(find("span.govuk-phase-banner__text")).to have_link "feedback", href: "mailto:email@example.gov.uk", class: "govuk-link"
  end

  context "when the app is configured as a preview for designers" do
    around do |example|
      ClimateControl.modify(CONTENTFUL_PREVIEW_APP: "true") do
        example.run
      end
    end

    it "renders a preview banner" do
      # banner.preview.tag
      expect(find("strong.govuk-phase-banner__content__tag")).to have_text "preview"
      # banner.preview.message
      expect(find("span.govuk-phase-banner__text")).to have_text "This environment is only for previewing Contentful changes before publishing."
    end
  end
end
