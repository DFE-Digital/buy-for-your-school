RSpec.feature "Journey continue button behaviour" do
  let(:user) { create(:user) }
  let(:category) { create(:category, :catering) }
  let(:journey) { create(:journey, user:, category:) }
  let(:section_b) { create(:section, title: "Section B", journey:) }

  before do
    user_is_signed_in(user:)
  end

  context "when a task has a single step and the user answers it" do
    before do
      task = create(:task, title: "Long text task", section: section_b)
      create(:step, :long_text, title: "Describe what you need", task:, order: 0)
      visit "/journeys/#{journey.id}"
    end

    scenario "the user is returned to the same place in the task list " do
      click_first_link_in_section_list

      fill_in "answer[response]", with: "This is my long answer"

      click_continue

      expect(page).to have_breadcrumbs ["Dashboard", "Create specification"]

      answer = LongTextAnswer.last

      expect(page).to have_current_path(journey_url(journey, anchor: answer.step.id))
    end
  end

  context "when a task has many steps" do
    let(:section_a) { create(:section, title: "Section A", journey:) }

    before do
      task_with_multiple_steps = create(:task, title: "Task with multiple steps", section: section_a)
      create(:step, :radio, title: "Which service do you need?", options: [{ "value" => "Catering" }], task: task_with_multiple_steps, order: 0)
      create(:step, :short_text, title: "What email address did you use?", task: task_with_multiple_steps, order: 1)
      create(:step, :long_text, title: "Describe what you need", task: task_with_multiple_steps, order: 2)
      create(:step, :checkbox, title: "Everyday services that are required and need to be considered", options: [{ "value" => "Breakfast" }], task: task_with_multiple_steps, order: 3)
      visit "/journeys/#{journey.id}"
    end

    scenario "the user is taken straight to the next step" do
      click_first_link_in_section_list

      task = journey.sections.first.tasks.first

      choose "Catering"
      click_continue

      fill_in "answer[response]", with: "This is my short answer"
      click_continue

      fill_in "answer[response]", with: "This is my long answer"
      click_continue

      check "Breakfast"
      click_continue

      expect(page).to have_content "Task with multiple steps"
      expect(page).to have_current_path journey_task_url(journey, task)
    end

    scenario "when a task has not been started, it takes the user straight to the first step" do
      click_first_link_in_section_list

      expect(page).not_to have_content "Task with multiple steps"
      expect(page).to have_content "Catering"
    end
  end
end
