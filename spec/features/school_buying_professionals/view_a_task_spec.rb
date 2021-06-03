require "rails_helper"

feature "Users can view a task" do
  let(:user) { create(:user) }
  before { user_is_signed_in(user: user) }

  context "When there is a task with multiple steps" do
    it "the Task title takes you to the first step" do
      start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      expect(page).to have_content "Which service do you need?"
    end

    context "when a task has at least one answered step" do
      it "takes the user to the task page" do
        start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

        task = Task.find_by(title: "Task with multiple steps")
        step = task.steps.first
        create(:radio_answer, step: step)

        within(".app-task-list") do
          click_on "Task with multiple steps"
        end

        expect(page).to have_content("Task with multiple steps")
        expect(page).to have_content("Which service do you need?")
      end
    end

    it "the back link takes you to the journey page" do
      start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      click_on I18n.t("generic.button.back")
      expect(page).to have_content "Task with multiple steps"
    end

    it "shows a list of the task steps" do
      start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      # Unstarted tasks take the user straight to the first step so we have to go back
      click_on(I18n.t("generic.button.back"))

      expect(page).to have_content "Which service do you need?"
      expect(page).to have_content "Everyday services that are required and need to be considered" # TODO: #675 refactor multiple
    end

    it "does not show hidden steps" do
      start_journey_with_tasks_from_category(category: "section-with-visible-and-hidden-tasks.json")

      within(".app-task-list") do
        click_on "Task with visible and hidden steps"
      end

      expect(page).to_not have_content "You should NOT be able to see this question?"
      expect(page).to have_content "Which service do you need?"
    end

    it "has a back link on the step page that takes you to the check your answers page" do
      start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      click_on(I18n.t("generic.button.back"))

      expect(page).to have_content "Task with multiple steps"
    end

    it "allows the user to click on a step to supply an answer, and be taken to the next step" do
      start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      choose "Catering"
      click_on(I18n.t("generic.button.next"))

      expect(page).to have_content "What email address did you use?"
    end

    it "allows the user to click on a step to supply the last answer in a task, and be taken to the check your answers page" do
      start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      choose "Catering"
      click_on(I18n.t("generic.button.next"))

      fill_in "answer[response]", with: "This is my short answer"
      click_on(I18n.t("generic.button.next"))

      fill_in "answer[response]", with: "This is my long answer"
      click_on(I18n.t("generic.button.next"))

      check("Breakfast")
      click_on(I18n.t("generic.button.next"))

      expect(page).to have_content "Task with multiple steps"
      within(".govuk-summary-list") do
        expect(page).to have_content("Catering")
      end
    end
  end
end
