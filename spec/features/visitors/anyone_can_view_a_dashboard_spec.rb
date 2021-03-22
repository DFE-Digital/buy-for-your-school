require "rails_helper"

feature "Anyone can view a dashboard" do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID: "contentful-category-entry"
    ) do
      example.run
    end
  end

  scenario "Dashboard displays the title" do
    visit dashboard_path

    expect(page).to have_content(I18n.t("dashboard.header"))
  end

  scenario "Dashboard prompts user to start a new journey" do
    stub_contentful_category(fixture_filename: "radio-question.json")

    visit dashboard_path

    expect(page).to have_content(I18n.t("dashboard.create.header"))
    expect(page).to have_content(I18n.t("dashboard.create.body"))

    click_on(I18n.t("dashboard.create.link"))

    expect(page).to have_content(I18n.t("specifying.start_page.page_title"))
    expect(page).to have_content("Which service do you need?")
    expect(page).to have_content("Not started")
  end
end
