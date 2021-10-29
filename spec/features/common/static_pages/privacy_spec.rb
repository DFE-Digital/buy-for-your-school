RSpec.feature "Privacy" do
  before do
    Page.create!(
      title: "Privacy",
      slug: "privacy",
      body: "# **Privacy notice**",
    )
    visit "/privacy"
  end

  describe "body" do
    scenario "contains the expected privacy content" do
      expect(page).to have_text("Privacy notice")
      expect(page).to have_title("Privacy")
    end
  end

  describe "footer" do
    scenario "provides an email address for the service and expected links" do
      within("footer") do
        expect(page).to have_text "For privacy information for this service, or to request the deletion of any personal data, email email@example.gov.uk"
        expect(page).to have_link "email@example.gov.uk", href: "mailto:email@example.gov.uk", class: "govuk-footer__link"
        expect(page).to have_link "Privacy", href: "/privacy", class: "govuk-footer__link"
      end
    end
  end
end
