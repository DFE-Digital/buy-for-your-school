feature "Users can see their catering specification" do
  scenario "HTML" do
    start_journey_from_category_and_go_to_question(category: "category-with-dynamic-liquid-template.json")

    choose("Catering")
    click_on(I18n.t("generic.button.next"))

    expect(page).to have_content(I18n.t("journey.specification.header"))

    within("article#specification") do
      expect(page).to have_content("Menus and ordering")
      expect(page).to have_content("Food standards")
      expect(page).to have_content("The school also requires the service to comply with the following non-mandatory food standards or schemes:")
      expect(page).to have_content("Catering")
    end
  end

  scenario "renders radio responses that have futher information" do
    stub_contentful_category(fixture_filename: "extended-radio-question.json")
    visit root_path
    click_on(I18n.t("generic.button.start"))

    click_first_link_in_task_list

    choose("Catering")
    fill_in "answer[further_information]", with: "The school needs the kitchen cleaned once a day"
    click_on(I18n.t("generic.button.next"))

    expect(page).to have_content(I18n.t("journey.specification.header"))

    within("article#specification") do
      expect(page).to have_content("Catering")
    end
  end

  context "when the spec is incomplete" do
    it "warns the user that the contents are in a partially completed state" do
      stub_contentful_category(fixture_filename: "extended-radio-question.json")
      visit root_path
      click_on(I18n.t("generic.button.start"))

      # Don't answer any questions to create a in progress spec

      expect(page).to have_content("You have not completed all the tasks. There may be information missing from your specification.")
    end
  end
end
