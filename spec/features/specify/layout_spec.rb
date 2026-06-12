RSpec.feature "Common layout element" do
  let(:accessibility_statement_url) { ApplicationHelper::ACCESSIBILITY_STATEMENT_URL }
  let(:privacy_notice_url) { ApplicationHelper::PRIVACY_NOTICE_URL }

  before do
    visit "/cms"
  end

  describe "header" do
    scenario "logo links back to homepage" do
      within ".govuk-header__logo" do
        expect(page).to have_link href: "https://www.gov.uk", class: "govuk-header__link--homepage"
      end
    end

    scenario "service name links back to the landing page" do
      within(".govuk-service-navigation__container") do
        # app.name
        expect(page).to have_link "Get help buying for schools", href: "/", class: "govuk-service-navigation__link"
      end
    end
  end

  describe "footer" do
    scenario "provides an email address for the service and expected links" do
      within("ul.govuk-footer__inline-list") do
        expect(page).to have_link "Accessibility", href: accessibility_statement_url, class: "govuk-footer__link"
        expect(page).to have_link "Terms and conditions", href: "/terms-and-conditions", class: "govuk-footer__link"
        expect(page).to have_link "Privacy", href: privacy_notice_url, class: "govuk-footer__link"
        expect(page).to have_link "Cookies", href: "/cookie_preferences", class: "govuk-footer__link"
      end
    end
  end
end
