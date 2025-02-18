RSpec.feature "Users can see their specification" do
  before { user_is_signed_in }

  scenario "HTML" do
    start_journey_from_category(category: "category-with-dynamic-liquid-template.json")
    click_first_link_in_section_list

    choose "Catering"
    click_continue
    click_view

    expect(page).to have_breadcrumbs ["Dashboard", "Create specification", "View specification"]
    expect(find(".govuk-caption-l")).to have_text "You are viewing: New specification"

    # journey.specification.header
    expect(find("h1.govuk-heading-xl")).to have_text "Your specification"
    expect(page).to have_text "You are viewing: New specification"

    within("article#specification") do
      expect(page).to have_content("Menus and ordering")
      expect(page).to have_content("Food standards")
      expect(page).to have_content("The school also requires the service to comply with the following non-mandatory food standards or schemes:")
      expect(page).to have_content("Catering")
    end
  end

  scenario "navigates back to the task list" do
    start_journey_from_category(category: "extended-radio-question.json")

    click_view

    click_breadcrumb "Create specification"
    expect(find("h1.govuk-heading-xl")).to have_text "Create your specification to procure catering for your school"
  end

  scenario "renders radio responses that have further information" do
    start_journey_from_category(category: "extended-radio-question.json")
    click_first_link_in_section_list

    choose "Catering"
    fill_in "answer[catering_further_information]", with: "The school needs the kitchen cleaned once a day"
    click_continue
    click_view

    expect(find(".govuk-caption-l")).to have_text "You are viewing: New specification"

    # journey.specification.header
    expect(find("h1.govuk-heading-xl")).to have_text "Your specification"

    within("article#specification") do
      expect(page).to have_content("Catering")
      expect(page).to have_content("The school needs the kitchen cleaned once a day")
    end
  end

  scenario "renders checkbox responses that have further information" do
    start_journey_from_category(category: "extended-checkboxes-question.json")
    click_first_link_in_section_list

    check "Yes"
    fill_in "answer[yes_further_information]", with: "More info for yes"
    check "No"
    fill_in "answer[no_further_information]", with: "More info for no"

    click_continue
    click_view

    # journey.specification.header
    expect(find("h1.govuk-heading-xl")).to have_text "Your specification"

    within("article#specification") do
      expect(page).to have_content("yes")
      expect(page).to have_content("More info for yes")
      expect(page).to have_content("no")
      expect(page).to have_content("More info for no")
    end
  end

  scenario "questions that are skipped can be identified" do
    start_journey_from_category(category: "skippable-checkboxes-question.json")
    click_first_link_in_section_list

    click_on "None of the above"
    click_view

    expect(page).to have_content("Skipped question detected")
  end

  context "when the spec is incomplete" do
    it "warns the user that the contents are in a partially completed state" do
      start_journey_from_category(category: "extended-radio-question.json")

      # Don't answer any questions to create a in progress spec

      click_view
      expect(page).to have_content("You have not completed all the tasks. There may be information missing from your specification.")
    end
  end

  context "when the spec template is configured using multiple sections" do
    it "renders both parts in the spec" do
      start_journey_from_category(category: "multiple-specification-templates.json")
      click_first_link_in_section_list

      choose "Catering"
      click_continue
      click_view

      # journey.specification.header
      expect(find("h1.govuk-heading-xl")).to have_text "Your specification"
    end
  end
end
