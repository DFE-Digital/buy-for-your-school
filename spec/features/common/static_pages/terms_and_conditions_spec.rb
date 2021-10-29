RSpec.feature "Terms and Conditions" do
  before do
    Page.create!(
      title: "Terms and conditions",
      slug: "terms_and_conditions",
      body: "# Terms and conditions",
    )
    visit "/terms-and-conditions"
  end

  describe "body" do
    scenario "contains the expected terms and conditions content" do
      expect(page).to have_text("Terms and conditions")
      expect(page).to have_title("Terms and conditions")
    end
  end

  describe "footer" do
    scenario "provides an email address for the service and expected links" do
      within("footer") do
        expect(page).to have_text "For privacy information for this service, or to request the deletion of any personal data, email email@example.gov.uk"
        expect(page).to have_link "email@example.gov.uk", href: "mailto:email@example.gov.uk", class: "govuk-footer__link"
        expect(page).to have_link "Accessibility", href: "/accessibility", class: "govuk-footer__link"
      end
    end
  end
end
