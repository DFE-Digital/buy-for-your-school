require "rails_helper"

feature "Users can see a start page for planning their purchase" do
  scenario "Start page content is shown on the root path" do
    visit root_path

    expect(page).to have_content(I18n.t("planning.start_page.page_title"))

    I18n.t("planning.start_page.overview_body").each do |paragraph|
      expect(page).to have_content(paragraph)
    end

    expect(page).to have_content(I18n.t("planning.start_page.who_for_title"))
    expect(page).to have_content(I18n.t("planning.start_page.who_for_can_use_body"))
    I18n.t("planning.start_page.who_for_can_use_list").each do |list_item|
      expect(page).to have_content(list_item)
    end
    expect(page).to have_content(I18n.t("planning.start_page.who_for_cannot_use_body"))
    I18n.t("planning.start_page.who_for_cannot_use_list").each do |list_item|
      expect(page).to have_content(list_item)
    end

    expect(page).to have_content(I18n.t("planning.start_page.how_service_works_title"))
    expect(page).to have_content(I18n.t("planning.start_page.how_service_works_document_body"))
    I18n.t("planning.start_page.how_service_works_document_list").each do |list_item|
      expect(page).to have_content(list_item)
    end
    expect(page).to have_content(I18n.t("planning.start_page.how_service_works_themes_body"))
    I18n.t("planning.start_page.how_service_works_themes_list").each do |list_item|
      expect(page).to have_content(list_item)
    end

    expect(page).to have_content(I18n.t("planning.start_page.pause_and_resume_body"))
  end
end
