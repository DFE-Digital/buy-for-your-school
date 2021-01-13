require "rails_helper"

feature "Users can see a start page for planning their purchase" do
  scenario "Start page content is shown on the root path" do
    visit root_path

    expect(page).to have_content(I18n.t("planning.start_page.page_title"))

    expect(page).to have_content(I18n.t("planning.start_page.overview_title"))
    I18n.t("planning.start_page.overview_body").each do |paragraph|
      expect(page).to have_content(paragraph)
    end

    expect(page).to have_content(I18n.t("planning.start_page.before_you_start_list_title"))
    I18n.t("planning.start_page.before_you_start_list_items").each do |list_item|
      expect(page).to have_content(list_item)
    end
    expect(page).to have_content(I18n.t("planning.start_page.before_you_start_body"))
  end
end
