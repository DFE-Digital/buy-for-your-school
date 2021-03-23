require "rails_helper"

feature "Anyone can navigate back to the service's home page" do
  scenario "Service name in the header links back to root_path" do
    visit root_path

    within(".govuk-header__content") do
      expect(page).to have_link(I18n.t("app.name"), href: "/")
    end
  end
end
