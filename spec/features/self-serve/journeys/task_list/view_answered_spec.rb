RSpec.feature "Users can view the task list" do
  let(:user) { create(:user) }
  let(:category) { create(:category, :catering, contentful_id: "contentful-category-entry") }
  let(:journey) { create(:journey, user:, category:) }
  let(:section_one) { create(:section, title: "Catering", journey:, contentful_id: "contentful-section-entry") }

  before do
    user_is_signed_in(user:)
  end

  context "when a task has more than one unanswered step" do
    before do
      task_with_multiple_steps = create(:task, title: "Task with multiple steps", section: section_one)
      create(:step, :radio, title: "Which service do you need?", options: [{ "value" => "Catering" }], task: task_with_multiple_steps, order: 0)
      create(:step, :short_text, title: "What email address did you use?", task: task_with_multiple_steps, order: 1)
      create(:step, :long_text, title: "Describe what you need", task: task_with_multiple_steps, order: 2)
      create(:step, :checkbox, title: "Everyday services that are required and need to be considered", options: [{ "value" => "Breakfast" }], task: task_with_multiple_steps, order: 3)

      visit "/journeys/#{journey.id}"
    end

    it "user can see a link to continue answering questions" do
      within ".app-task-list" do
        click_on "Task with multiple steps"
      end

      # /journeys/13848f65-ff88-46a3-8d35-59403a1cdbf2/steps/00966342-5d84-417d-bb78-dfe7383a196f
      expect(page).to have_a_step_path
      click_back

      # list of steps
      # /journeys/13848f65-ff88-46a3-8d35-59403a1cdbf2/tasks/8ee45edf-6808-4398-8498-ca8c4ab80e15
      expect(page).to have_a_task_path
      click_on "Continue answering these questions" # task.button.continue

      expect(page).to have_content "Which service do you need?"
      choose "Catering"
      click_continue
      click_back

      # list of steps
      # /journeys/13848f65-ff88-46a3-8d35-59403a1cdbf2/tasks/8ee45edf-6808-4398-8498-ca8c4ab80e15
      expect(page).to have_a_task_path

      click_on "Continue answering these questions" # task.button.continue

      expect(page).to have_content "What email address did you use?"
    end
  end

  # TODO: This feature spec is insufficient and should use "with an incomplete journey" context
  context "when a task with multiple steps has been completed" do
    before do
      task_with_multiple_steps = create(:task, title: "Task with multiple steps", section: section_one, order: 0)
      create(:step, :radio, title: "Which service do you need?", options: [{ "value" => "Catering" }], task: task_with_multiple_steps, order: 0)
      create(:step, :short_text, title: "What email address did you use?", task: task_with_multiple_steps, order: 1)
      create(:step, :long_text, title: "Describe what you need", task: task_with_multiple_steps, order: 2)
      create(:step, :checkbox, title: "Everyday services that are required and need to be considered", options: [{ "value" => "Breakfast" }], task: task_with_multiple_steps, order: 3)

      task_with_every_type_of_step = create(:task, title: "Task containing every type of step", section: section_one, order: 1)
      create(:step, :long_text, title: "Briefly describe what you are looking to procure", task: task_with_every_type_of_step, order: 0)
      create(:step, :short_text, title: "What email address did you use?", task: task_with_every_type_of_step, order: 1)

      visit "/journeys/#{journey.id}"
    end

    it "user can see a link to continue to the next task" do
      within ".app-task-list" do
        click_on "Task with multiple steps"
      end

      # /journeys/4742c871-ba8e-421e-8c6b-234494162410/steps/173f9eaf-e4ac-4826-8f2d-9b122517ee38
      expect(page).to have_a_step_path

      choose "Catering"
      click_continue

      fill_in "answer[response]", with: "email@example.com"
      click_continue

      fill_in "answer[response]", with: "I'm looking to procure..."
      click_continue

      check "Breakfast"
      click_continue

      # list of steps
      # /journeys/4742c871-ba8e-421e-8c6b-234494162410/tasks/557082fd-62ec-49d5-b863-4335d3fc6c41
      expect(page).to have_a_task_path
      click_on "Continue to the next task" # task.button.next

      expect(page).to have_content "Briefly describe what you are looking to procure"
      click_back
      # list of steps
      # /journeys/4742c871-ba8e-421e-8c6b-234494162410/tasks/d0048fc2-04b8-4fe4-97fc-7b1e6880b83b
      expect(page).to have_a_task_path
      expect(page).to have_content "Task containing every type of step"
    end
  end

  context "when a task includes a step that has been answered" do
    let(:section_two) { create(:section, title: "Section with a single task", journey:, contentful_id: "contentful-section-entry") }

    before do
      task_with_single_step = create(:task, title: "Task with a single step", section: section_two)
      create(:step, :checkbox, title: "Everyday services that are required and need to be considered", options: [{ "value" => "Lunch" }], task: task_with_single_step, order: 0)

      visit "/journeys/#{journey.id}"
    end

    it "shows the section title" do
      within(".app-task-list") do
        expect(page).to have_content "Section with a single task"
      end
    end

    it "shows the task title, not the step title" do
      within(".app-task-list") do
        expect(page).to have_content "Task with a single step"
        expect(page).not_to have_content "Everyday services that are required and need to be considered" # TODO: #675 refactor multiple
      end
    end

    it "has a back link on the step page that takes you to the journey page" do
      within(".app-task-list") do
        click_on "Task with a single step"
      end

      # /journeys/3b5753b5-5e4c-41a7-822b-76a2e47ffdd6/steps/e56a179e-d8df-4ed7-8852-acee85db415a
      expect(page).to have_a_step_path
      click_back
      # journey page
      # /journeys/3b5753b5-5e4c-41a7-822b-76a2e47ffdd6
      expect(page).to have_a_journey_path
      expect(page).to have_content "Section with a single task"
    end

    it "allows the user to complete the step, and returns to the journey page" do
      within(".app-task-list") do
        click_on "Task with a single step"
      end

      # /journeys/a0e6a4fc-a140-4280-a8a6-b23f0ce81b86/steps/db474ce5-d137-49ff-93c5-0e636d9a58df
      expect(page).to have_a_step_path
      check "Lunch"
      click_continue

      # journey page
      # /journeys/a0e6a4fc-a140-4280-a8a6-b23f0ce81b86
      expect(page).to have_a_journey_path
      expect(page).to have_content "Section with a single task"
      within(".app-task-list") do
        expect(page).to have_content "Completed" # task_list.status.completed
      end
    end
  end
end
