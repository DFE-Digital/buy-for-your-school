RSpec.feature "Checkbox Question" do
  before { user_is_signed_in }

  scenario "user can select multiple answers" do
    start_journey_from_category(category: "checkboxes-question.json")
    click_first_link_in_section_list

    check "Breakfast"
    check "Lunch"

    click_continue

    click_first_link_in_section_list

    expect(page).to have_checked_field "answer-response-breakfast-field"
    expect(page).to have_checked_field "answer-response-lunch-field"
  end

  scenario "options follow the capitalisation given" do
    start_journey_from_category(category: "checkboxes-question.json")
    click_first_link_in_section_list

    expect(page).to have_content "Morning break"
  end

  context "when extra configuration is passed to collect further info" do
    scenario "asks the user for further information" do
      start_journey_from_category(category: "extended-checkboxes-question.json")
      click_first_link_in_section_list

      check "Yes"
      fill_in "answer[yes_further_information]", with: "The first piece of further information"

      check "No"

      # It should not create a label when text for one isn't provided
      expect(page).not_to have_content "No_further_information"

      within "span.govuk-visually-hidden" do
        # Default the hidden label to something understandable for screen readers
        expect(page).to have_content "Optional further information"
      end

      fill_in "answer[no_further_information]", with: "A second piece of further information"

      # We are testing a value that includes a comma
      check "Other, please specify"
      fill_in "answer[other_please_specify_further_information]", with: "Other information"

      click_continue

      click_first_link_in_section_list

      expect(page).to have_checked_field("Yes")
      expect(find_field("answer-yes-further-information-field").value)
        .to eql("The first piece of further information")

      expect(page).to have_checked_field("No")
      expect(find_field("answer-no-further-information-field").value)
        .to eql("A second piece of further information")

      expect(page).to have_checked_field("Other, please specify")
      expect(find_field("answer-other-please-specify-further-information-field").value)
        .to eql("Other information")
    end
  end

  context "when extended question is of type single" do
    scenario "a single text field is displayed" do
      start_journey_from_category(category: "extended-checkboxes-question.json")
      click_first_link_in_section_list
      check "Yes"

      expect(page).to have_selector "input#answer-yes-further-information-field"
    end
  end

  context "when extended question is of type long" do
    scenario "a long text area is displayed" do
      start_journey_from_category(category: "extended-long-answer-checkboxes-question.json")
      click_first_link_in_section_list
      check "Yes"

      expect(page).to have_selector "textarea#answer-yes-further-information-field"
    end
  end

  context "when there is no extended question" do
    scenario "no extra text field is displayed" do
      start_journey_from_category(category: "checkboxes-question.json")
      click_first_link_in_section_list

      expect(page).not_to have_selector "textarea#answer-yes-further-information-field"
      expect(page).not_to have_selector "input#answer-yes-further-information-field"
    end
  end
end
