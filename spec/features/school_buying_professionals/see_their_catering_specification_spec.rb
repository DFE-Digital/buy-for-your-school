feature "Users can see their catering specification" do
  before { user_is_signed_in }

  scenario "HTML" do
    start_journey_from_category_and_go_to_question(category: "category-with-dynamic-liquid-template.json")

    choose("Catering")
    click_on(I18n.t("generic.button.next"))
    click_on(I18n.t("journey.specification.button"))

    expect(page).to have_content(I18n.t("journey.specification.header"))

    within("article#specification") do
      expect(page).to have_content("Menus and ordering")
      expect(page).to have_content("Food standards")
      expect(page).to have_content("The school also requires the service to comply with the following non-mandatory food standards or schemes:")
      expect(page).to have_content("Catering")
    end
  end

  scenario "navigates back to the task list" do
    start_journey_from_category(category: "extended-radio-question.json")

    click_on(I18n.t("journey.specification.button"))

    click_on(I18n.t("generic.button.back"))
    expect(page).to have_content(I18n.t("specifying.start_page.page_title"))
  end

  scenario "renders radio responses that have futher information" do
    start_journey_from_category_and_go_to_question(category: "extended-radio-question.json")

    choose("Catering")
    fill_in "answer[catering_further_information]", with: "The school needs the kitchen cleaned once a day"
    click_on(I18n.t("generic.button.next"))
    click_on(I18n.t("journey.specification.button"))

    expect(page).to have_content(I18n.t("journey.specification.header"))

    within("article#specification") do
      expect(page).to have_content("Catering")
      expect(page).to have_content("The school needs the kitchen cleaned once a day")
    end
  end

  scenario "renders checkbox responses that have further information" do
    start_journey_from_category_and_go_to_question(category: "extended-checkboxes-question.json")

    check("Yes")
    fill_in "answer[yes_further_information]", with: "More info for yes"
    check("No")
    fill_in "answer[no_further_information]", with: "More info for no"

    click_on(I18n.t("generic.button.next"))
    click_on(I18n.t("journey.specification.button"))

    expect(page).to have_content(I18n.t("journey.specification.header"))

    within("article#specification") do
      expect(page).to have_content("yes")
      expect(page).to have_content("More info for yes")
      expect(page).to have_content("no")
      expect(page).to have_content("More info for no")
    end
  end

  scenario "questions that are skipped can be identified" do
    start_journey_from_category_and_go_to_question(category: "skippable-checkboxes-question.json")

    click_on("None of the above")
    click_on(I18n.t("journey.specification.button"))

    expect(page).to have_content("Skipped question detected")
  end

  context "when the spec is incomplete" do
    it "warns the user that the contents are in a partially completed state" do
      start_journey_from_category(category: "extended-radio-question.json")

      # Don't answer any questions to create a in progress spec

      click_on(I18n.t("journey.specification.button"))
      expect(page).to have_content("You have not completed all the tasks. There may be information missing from your specification.")
    end
  end

  context "when the spec template is configured using multiple sections" do
    it "renders both parts in the spec" do
      start_journey_from_category_and_go_to_question(category: "multiple-specification-templates.json")

      choose("Catering")
      click_on(I18n.t("generic.button.next"))
      click_on(I18n.t("journey.specification.button"))

      expect(page).to have_content(I18n.t("journey.specification.header"))
      expect(page).to have_content("Part 1")
      expect(page).to have_content("Part 2")
    end
  end
end
