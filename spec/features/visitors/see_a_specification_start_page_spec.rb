require "rails_helper"

feature "Users can see a start page for specifying their purchase" do
  scenario "Start page content is shown on the root path" do
    visit root_path

    expect(page).to have_content(I18n.t("specifying.start_page.page_title"))

    I18n.t("specifying.start_page.overview_body").each do |paragraph|
      expect(page).to have_content(paragraph)
    end

    expect(page).to have_content(I18n.t("specifying.start_page.who_for_title"))
    expect(page).to have_content(I18n.t("specifying.start_page.who_for_can_use_body"))

    expect(page).to have_content("are responsible for procuring a new catering service for a school")
    expect(page).to have_link("procuring a new catering service", href: "/planning")
    expect(page).to have_content(I18n.t("specifying.start_page.who_for_can_use_list")[1])
    expect(page).to have_content(I18n.t("specifying.start_page.who_for_can_use_list")[2])

    expect(page).to have_content(I18n.t("specifying.start_page.who_for_cannot_use_body"))
    I18n.t("specifying.start_page.who_for_cannot_use_list").each do |list_item|
      expect(page).to have_content(list_item)
    end

    expect(page).to have_content(I18n.t("specifying.start_page.how_service_works_title"))
    expect(page).to have_content(I18n.t("specifying.start_page.how_service_works_document_body"))
    I18n.t("specifying.start_page.how_service_works_document_list").each do |list_item|
      expect(page).to have_content(list_item)
    end
    expect(page).to have_content(I18n.t("specifying.start_page.how_service_works_themes_body"))
    I18n.t("specifying.start_page.how_service_works_themes_list").each do |list_item|
      expect(page).to have_content(list_item)
    end

    expect(page).to have_content(I18n.t("specifying.start_page.pause_and_resume_body"))
  end

  scenario "The start button takes the user to the dashboard" do
    visit root_path

    click_on(I18n.t("generic.button.start"))

    expect(page).to have_content(I18n.t("dashboard.header"))
  end
end
