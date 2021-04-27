require "rails_helper"

feature "Users can view a task" do
  let(:user) { create(:user) }
  before { user_is_signed_in(user: user) }

  context "When there is a task with multiple steps" do
    it "the Task title takes you to a Task page" do
      start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      expect(page).to have_content "Task with multiple steps"
    end

    it "the back link takes you to the journey page" do
      start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      expect(page).to have_content "Back"

      click_on "Back"
      expect(page).to have_content "Task with multiple steps"
    end

    it "shows a list of the task's steps" do
      start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      expect(page).to have_content "Which service do you need?"
      expect(page).to have_content "Everyday services that are required and need to be considered"
    end

    it "does not show hidden steps" do
      start_journey_with_tasks_from_category(category: "section-with-visible-and-hidden-tasks.json")

      within(".app-task-list") do
        click_on "Task with visible and hidden steps"
      end

      expect(page).to_not have_content "You should NOT be able to see this question?"
      expect(page).to have_content "Which service do you need?"
    end

    it "has a back link on the step page that takes you to the task list" do
      start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      click_on "Which service do you need?"
      click_on "Back"

      expect(page).to have_content "Task with multiple steps"
    end

    it "allows the user to click on a step to supply an answer, and returns to the task page" do
      start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      click_on "Which service do you need?"
      choose "Catering"
      click_on "Continue"

      expect(page).to have_content "Task with multiple steps"
      within(".app-task-list") do
        expect(page).to have_content("Complete")
      end
    end
  end
end
