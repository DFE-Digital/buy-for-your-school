RSpec.feature "Skippable steps" do
  before do
    user_is_signed_in
    start_journey_from_category(category: "skippable-checkboxes-question.json")
    click_first_link_in_section_list
  end

  context "when the question is skippable" do
    it "permits an answer to be omitted" do
      click_continue
      expect(find(".govuk-error-message")).to have_content "Please complete this field to continue."

      check "Lunch"
      check "Dinner"
      click_continue

      click_first_link_in_section_list

      click_on "None of the above"

      within ".app-task-list" do
        expect(page).to have_content "Complete"
      end

      click_first_link_in_section_list

      expect(page).not_to have_checked_field "Lunch"
      expect(CheckboxAnswers.last.skipped).to be true
    end

    context "and the question has already been skipped" do
      scenario "providing an answer marks the question as not being skipped" do
        click_on "None of the above"

        within ".app-task-list" do
          expect(page).to have_content "Complete"
        end

        click_first_link_in_section_list

        check "Lunch"
        check "Dinner"
        click_update

        expect(CheckboxAnswers.last.skipped).to be false
      end
    end
  end
end
