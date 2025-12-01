RSpec.feature "Toggling additional steps" do
  let(:step) { create(:step, :additional_steps) }
  let(:journey) { step.task.section.journey }
  let(:user) { journey.user }

  context "when there are hidden steps" do
    before do
      # build dependent steps (used by additional_steps trait)
      create(:step, :statement,
             contentful_id: "123",
             order: 1,
             title: "statement!",
             hidden: true,
             task: step.task)

      create(:step, :short_text,
             contentful_id: "456",
             order: 2,
             title: "question?",
             hidden: true,
             task: step.task)

      user_is_signed_in(user:)
      visit_journey
    end

    it "changes the state badge" do
      # enter task and be taken to additional step question
      click_on "Task title"

      # answer question revealing additional steps
      choose "yes"
      click_continue

      # continue to newly revealed statement step
      expect(find("h2", text: "Heading 2")).to be_present

      # acknowledge the statement
      click_continue

      # FIXME: continue to newly revealed question step
      # expect(find("label.govuk-label--l")).to have_text "question?"

      # list of steps
      expect(all("dt.govuk-summary-list__key")[1]).to have_text "statement!"
      expect(all("dt.govuk-summary-list__key")[2]).to have_text "question?"

      # go back
      click_on "Return to task list"
      # list of tasks
      expect(find("strong.app-task-list__tag")).to have_text "In progress"
    end
  end

  context "when there are no additional steps" do
    before do
      user_is_signed_in(user:)
      visit_journey
    end

    it "does not change the state badge" do
      click_on "Task title"
      choose "yes"
      click_continue
      expect(find("strong.app-task-list__tag")).to have_text "Completed"
    end
  end

  # CMS: this test was written twice
  context "when Contentful entry includes a 'show additional question' rule Version 1" do
    scenario "additional questions are shown" do
      start_journey_from_category(category: "show-one-additional-question.json")
      click_first_link_in_section_list

      choose "School expert"
      click_continue

      # This question should be made visible after the previous step
      expect(page).not_to have_content("What colour is the sky?")
      click_on("Hidden field with additional question task")
      choose("Red")
      click_continue

      # This question should only be made visible after the previous step
      click_on("Hidden field task")
      choose("School expert")
      click_continue
    end
  end

  # CMS: this test was written twice
  context "when Contentful entry includes a 'show additional question' rule Version 2" do
    scenario "an additional question is shown" do
      start_journey_from_category(category: "show-one-additional-question.json")
      click_first_link_in_section_list

      choose "School expert"
      click_continue

      # This question should be made visible after the previous step
      click_on "Hidden field with additional question task"
      choose "Red"
      click_continue

      # This question should be made visible after the previous step
      click_on "Hidden field task"
      choose "School expert"
      click_continue

      # Edit the first question to remove the chain of hidden questions
      click_on "One additional question task"
      choose "None"
      click_update

      expect(page).not_to have_content "Hidden field with additional question task"
      expect(page).not_to have_content "Hidden field task"

      # Edit the first question to add back the full chain of hidden questions
      click_on "One additional question task"
      choose "School expert"
      click_update

      expect(page).to have_content "Hidden field with additional question task"
      expect(page).to have_content "Hidden field task"
    end
  end
end
