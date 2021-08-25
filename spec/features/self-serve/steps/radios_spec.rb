RSpec.feature "Radio Question" do
  before { user_is_signed_in }

  context "when extra configuration is passed to collect further info" do
    scenario "asks the user for further information" do
      start_journey_from_category(category: "extended-radio-question.json")
      click_first_link_in_section_list

      choose "Catering"

      # It should not create a label when one isn't specified
      expect(page).not_to have_text "No_further_information"

      within "span.govuk-visually-hidden" do
        # Default the hidden label to something understandable for screen readers
        expect(page).to have_text "Optional further information"
      end

      fill_in "answer[catering_further_information]", with: "The school needs the kitchen cleaned once a day"

      click_continue

      click_first_link_in_section_list

      expect(page).to have_checked_field "Catering"

      answer = find_field("answer-catering-further-information-field").value
      expect(answer).to eql "The school needs the kitchen cleaned once a day"
    end
  end

  context "when extended question is of type single" do
    scenario "a single text field is displayed" do
      start_journey_from_category(category: "extended-radio-question.json")
      click_first_link_in_section_list
      choose "Catering"
      expect(page).to have_selector "input#answer-catering-further-information-field"
    end
  end

  context "when extended question is of type long" do
    scenario "a long text area is displayed" do
      start_journey_from_category(category: "extended-long-answer-radio-question.json")
      click_first_link_in_section_list
      choose "Catering"
      expect(page).to have_selector "textarea#answer-catering-further-information-field"
    end
  end

  context "when there is no extended question" do
    scenario "no extra text field is displayed" do
      start_journey_from_category(category: "radio-question.json")
      click_first_link_in_section_list

      expect(page).not_to have_selector "textarea#answer-catering-further-information-field"
      expect(page).not_to have_selector "input#answer-catering-further-information-field"
    end
  end

  context "when an 'or separator' has been configured" do
    scenario "shows an or separator" do
      start_journey_from_category(category: "radio-question-with-separator.json")
      click_first_link_in_section_list

      within ".govuk-radios__divider" do
        expect(page).to have_text "or"
      end

      # TODO: this test needs to be written better
      #
      # Check that the "Or" separator appears in the correct position
      expect(page.body.index("Catering") > page.body.index("or")).to eq(true)
      expect(page.body.index("or") < page.body.index("Cleaning")).to eq(true)
    end
  end
end
