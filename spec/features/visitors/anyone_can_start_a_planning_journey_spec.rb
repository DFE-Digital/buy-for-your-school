require "rails_helper"

feature "Anyone can start the planning journey" do
  scenario "Start page includs a call to action" do
    stub_get_contentful_entry

    visit root_path

    click_on(I18n.t("generic.button.start"))

    expect(page).to have_content("Which service do you need?")
    expect(page).to have_content("Tell us which service you need.")
    expect(page).to have_content("Catering")
    expect(page).to have_content("Cleaning")

    choose("Catering")

    click_on(I18n.t("generic.button.soft_finish"))
  end

  scenario "an answer must be provided" do
    stub_get_contentful_entry

    visit root_path

    click_on(I18n.t("generic.button.start"))

    # Omit a choice

    click_on(I18n.t("generic.button.soft_finish"))

    expect(page).to have_content("can't be blank")
  end

  scenario "a Contentful entry_id does not exist" do
    contentful_client = stub_contentful_client

    allow(contentful_client).to receive(:entry)
      .with(anything)
      .and_raise(GetContentfulQuestion::EntryNotFound.new("The following Contentful error could not be found: sss "))

    visit root_path

    click_on(I18n.t("generic.button.start"))

    expect(page).to have_content(I18n.t("errors.contentful_entry_not_found.page_title"))
    expect(page).to have_content(I18n.t("errors.contentful_entry_not_found.page_body"))
  end
end
