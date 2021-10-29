RSpec.feature "Common layout element" do
  before do
    visit "/"
  end

  describe "header" do
    scenario "logo links back to gov.uk" do
      within ".govuk-header__logo" do
        expect(page).to have_link href: "https://www.gov.uk", class: "govuk-header__link--homepage"
      end
    end

    scenario "service name links back to the landing page" do
      within(".govuk-header__content") do
        # app.name
        expect(page).to have_link "Get help buying for schools", href: "/", class: "govuk-header__link--service-name"
      end
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
