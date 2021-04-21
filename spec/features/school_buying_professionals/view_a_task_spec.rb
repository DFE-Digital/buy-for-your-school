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
  end
end
