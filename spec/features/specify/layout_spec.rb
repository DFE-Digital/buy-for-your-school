RSpec.feature "Common layout element" do
  before do
    visit "/cms"
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
        expect(page).to have_link "Get help buying for schools", href: "/", class: "govuk-header__service-name"
      end
    end
  end

  describe "footer" do
    scenario "provides an email address for the service and expected links" do
      within("ul.govuk-footer__inline-list") do
        expect(page).to have_link "Accessibility statement", href: "/accessibility", class: "govuk-footer__link"
        expect(page).to have_link "Terms and Conditions", href: "/terms-and-conditions", class: "govuk-footer__link"
        expect(page).to have_link "Privacy notice", href: "/privacy", class: "govuk-footer__link"
      end
    end
  end
end
