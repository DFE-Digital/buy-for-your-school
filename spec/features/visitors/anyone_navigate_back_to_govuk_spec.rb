require "rails_helper"

feature "Anyone can navigate back to govuk" do
  scenario "Logo in the header links back to gov.uk" do
    visit root_path

    within(".govuk-header__logo") do
      expect(page).to have_link(href: "https://www.gov.uk")
    end
  end
end
