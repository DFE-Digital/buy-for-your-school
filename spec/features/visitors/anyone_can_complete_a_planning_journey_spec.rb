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

  context "when the starter question has a next question" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_PLANNING_START_ENTRY_ID: "47EI2X2T5EDTpJX9WjRR9p"
      ) do
        example.run
      end
    end

    scenario "there are 2 questions to answer" do
      visit root_path

      stub_get_contentful_entry(
        entry_id: "47EI2X2T5EDTpJX9WjRR9p",
        fixture_filename: "has-next-question-example.json"
      )
      click_on(I18n.t("generic.button.start"))

      choose("Catering")

      stub_get_contentful_entry(
        entry_id: "5lYcZs1ootDrOnk09LDLZg",
        fixture_filename: "no-next-question-example.json"
      )
      click_on(I18n.t("generic.button.soft_finish"))

      choose("Stationary")
      click_on(I18n.t("generic.button.soft_finish"))

      expect(page).to have_content("Catering")
      expect(page).to have_content("Stationary")
    end
  end

  scenario "a Contentful entry_id does not exist" do
    contentful_client = stub_contentful_client

    allow(contentful_client).to receive(:entry)
      .with(anything)
      .and_raise(GetContentfulEntry::EntryNotFound.new("The following Contentful error could not be found: sss "))

    visit root_path

    click_on(I18n.t("generic.button.start"))

    expect(page).to have_content(I18n.t("errors.contentful_entry_not_found.page_title"))
    expect(page).to have_content(I18n.t("errors.contentful_entry_not_found.page_body"))
  end

  context "when Contentful entry is of type short_text" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_PLANNING_START_ENTRY_ID: "hfjJgWRg4xiiiImwVRDtZ"
      ) do
        example.run
      end
    end

    scenario "user can answer using free text" do
      stub_get_contentful_entry(
        entry_id: "hfjJgWRg4xiiiImwVRDtZ",
        fixture_filename: "short-text-question-example.json"
      )

      visit root_path
      click_on(I18n.t("generic.button.start"))

      fill_in "answer[response]", with: "email@example.com"
      click_on(I18n.t("generic.button.soft_finish"))

      expect(page).to have_content("Email@example")
    end
  end

  context "when Contentful entry model wasn't a type of question" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_PLANNING_START_ENTRY_ID: "6EKsv389ETYcQql3htK3Z2"
      ) do
        example.run
      end
    end

    scenario "returns an error message" do
      stub_get_contentful_entry(
        entry_id: "6EKsv389ETYcQql3htK3Z2",
        fixture_filename: "an-unexpected-model-example.json"
      )

      visit root_path

      click_on(I18n.t("generic.button.start"))

      expect(page).to have_content(I18n.t("errors.unexpected_contentful_model.page_title"))
      expect(page).to have_content(I18n.t("errors.unexpected_contentful_model.page_body"))
    end
  end

  context "when Contentful question entry wasn't an expected type" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_PLANNING_START_ENTRY_ID: "8as7df68uhasdnuasdf"
      ) do
        example.run
      end
    end

    scenario "returns an error message" do
      stub_get_contentful_entry(
        entry_id: "8as7df68uhasdnuasdf",
        fixture_filename: "an-unexpected-question-type-example.json"
      )

      visit root_path

      click_on(I18n.t("generic.button.start"))

      expect(page).to have_content(I18n.t("errors.unexpected_contentful_question_type.page_title"))
      expect(page).to have_content(I18n.t("errors.unexpected_contentful_question_type.page_body"))
    end
  end
end
