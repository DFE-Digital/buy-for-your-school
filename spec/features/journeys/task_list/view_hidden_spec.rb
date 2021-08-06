RSpec.feature "Users can view the task list" do
  let(:user) { create(:user) }

  before do
    user_is_signed_in(user: user)
    # TODO: replace fixture with factory
    start_journey_from_category(category: fixture)
  end

  context "when a task includes an initially HIDDEN step" do
    let(:fixture) { "hidden-field.json" }

    it "does not appear in the task list" do
      expect(page).not_to have_content "Hidden field task" # > hidden_field_task.json
      expect(page).to have_content "Shown field task" # > shown_field_task.json
    end

    it "shows the section title" do
      start_journey_from_category(category: "section-with-single-hidden-task.json")
      within(".app-task-list") do
        expect(page).to have_content "Section with a hidden task" # > hidden_task_section.json
      end
    end

    context "when that step becomes visible" do
      let(:fixture) { "show-one-additional-question-in-order.json" }

      it "appears in the order defined in Contentful rather than at the end" do
        # Simulate the bug by changing the created_at to a time that incorrectly
        # puts the hidden record at the bottom of the list
        Step.find_by(title: "What support do you have available?").update!(created_at: 3.days.ago)
        Step.find_by(title: "What email address did you use?").update!(created_at: 2.days.ago)
        Step.find_by(title: "What colour is the sky?").update!(created_at: 1.day.ago)

        click_on "One additional question task" # > show-one-additional-question-in-order-task.json
        expect(page).to have_current_path %r{/journeys/.*/steps/.*}
        click_back
        # list of steps
        steps = find_all(".govuk-summary-list__row")
        within(".govuk-summary-list") do
          expect(steps[0]).to have_content "What support do you have available?"
          # Hidden field "What colour is the sky?" is correctly omitted at this point
          expect(steps[1]).to have_content "What email address did you use?"
        end

        # Answer the first question to unlock "What colour is the sky?"
        first(".govuk-summary-list__row").click_on "Change" # generic.button.change_answer
        choose "School expert"
        click_continue

        # We get taken to the next question so we go back to the task page
        click_back

        # Check that "What colour is in the sky added to the correct place in the list"
        steps = find_all(".govuk-summary-list__row")
        within(".govuk-summary-list") do
          expect(steps[0]).to have_content "What support do you have available?"
          expect(steps[1]).to have_content "What colour is the sky?"
          expect(steps[2]).to have_content "What email address did you use?"
        end
      end
    end
  end
end
