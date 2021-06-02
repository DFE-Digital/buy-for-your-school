require "rails_helper"

feature "Anyone can view a dashboard" do
  before { user_is_signed_in }

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

  scenario "user can view existing specifications" do
    user = create(:user)
    user_is_signed_in(user: user)
    create(:journey, user: user, created_at: Time.local(2021, 2, 15, 12, 0, 0))

    visit dashboard_path

    expect(page).to have_content(I18n.t("dashboard.existing.header"))
    expect(page).to have_content(I18n.t("dashboard.existing.body"))

    expect(page).to have_content("15 February 2021")
  end

  scenario "user can see the start specification content on the dashboard" do
    user = create(:user)
    user_is_signed_in(user: user)

    visit dashboard_path

    expect(page).to have_content(I18n.t("dashboard.create.header"))
    expect(page).to have_content(I18n.t("dashboard.create.body"))

    expect(page).to have_button(I18n.t("dashboard.create.button"))
  end

  scenario "user can start a new specification from the dashboard" do
    stub_contentful_category(fixture_filename: "radio-question.json")

    visit dashboard_path

    click_on(I18n.t("dashboard.create.button"))

    expect(page).to have_content(I18n.t("specifying.start_page.page_title"))
    expect(page).to have_content("Which service do you need?")
    expect(page).to have_content("Not started")
  end
end
