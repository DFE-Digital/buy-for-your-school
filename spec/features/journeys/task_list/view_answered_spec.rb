RSpec.feature "Users can view the task list" do
  let(:user) { create(:user) }
  let(:fixture) { "section-with-multiple-tasks.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: replace fixture with factory
    start_journey_from_category(category: fixture)
  end

  context "when a task has more than one unanswered step" do
    it "user can see a link to continue answering questions" do
      within ".app-task-list" do
        click_on "Task with multiple steps" # > checkboxes-and-radio-task.json
      end

      expect(page).to have_current_path %r{/journeys/.*/steps/.*}
      click_back

      # list of steps
      expect(page).to have_current_path %r{/journeys/.*/tasks/.*}
      click_on "Continue answering these questions" # task.button.continue

      expect(page).to have_content "Which service do you need?"
      choose "Catering"
      click_continue
      click_back

      # list of steps
      expect(page).to have_current_path %r{/journeys/.*/tasks/.*}
      click_on "Continue answering these questions" # task.button.continue

      expect(page).to have_content "What email address did you use?"
    end
  end

  # TODO: This feature spec is insufficient and should use "with an incomplete journey" context
  context "when a task with multiple steps has been completed" do
    it "user can see a link to continue to the next task" do
      # category - section-with-multiple-tasks
      #   section - multiple-tasks-section
      #     tasks
      #       1. checkboxes-task             "Task with a single step"
      #       2. checkboxes-and-radio-task   "Task with multiple steps"
      #       3. every-question-type-task    "Task containing every type of step"
      #

      # task 1 step 2
      within ".app-task-list" do
        click_on "Task with multiple steps" # > checkboxes-and-radio-task.json
      end

      expect(page).to have_current_path %r{/journeys/.*/steps/.*}

      choose "Catering"
      click_continue

      fill_in "answer[response]", with: "email@example.com"
      click_continue

      fill_in "answer[response]", with: "I'm looking to procure..."
      click_continue

      check "Breakfast"
      click_continue

      # list of steps
      expect(page).to have_current_path %r{/journeys/.*/tasks/.*}
      click_on "Continue to the next task" # task.button.next

      # task 1 step 3 long-text-question
      expect(page).to have_content "Briefly describe what you are looking to procure"
      click_back
      # list of steps
      expect(page).to have_current_path %r{/journeys/.*/tasks/.*}
      expect(page).to have_content "Task containing every type of step"
    end
  end

  context "when a task includes a step that has been answered" do
    let(:fixture) { "section-with-single-task.json" }

    it "shows the section title" do
      within(".app-task-list") do
        expect(page).to have_content "Section with a single task" # > single_task_section.json
      end
    end

    it "shows the task title, not the step title" do
      within(".app-task-list") do
        expect(page).to have_content "Task with a single step" # > checkboxes_task.json
        expect(page).not_to have_content "Everyday services that are required and need to be considered" # TODO: #675 refactor multiple
      end
    end

    it "has a back link on the step page that takes you to the journey page" do
      within(".app-task-list") do
        click_on "Task with a single step" # > checkboxes_task.json
      end

      expect(page).to have_current_path %r{/journeys/.*/steps/.*}
      click_back
      # journey page
      expect(page).to have_current_path %r{/journeys/.*}
      expect(page).to have_content "Section with a single task"
    end

    it "allows the user to complete the step, and returns to the journey page" do
      within(".app-task-list") do
        click_on "Task with a single step" # > checkboxes_task.json
      end

      expect(page).to have_current_path %r{/journeys/.*/steps/.*}
      check "Lunch"
      click_continue

      # journey page
      expect(page).to have_current_path %r{/journeys/.*}
      expect(page).to have_content "Section with a single task"
      within(".app-task-list") do
        expect(page).to have_content "Completed" # task_list.status.completed
      end
    end
  end
end
