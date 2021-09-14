# TODO: replace with factories and check HTML/classes
RSpec.feature "Journey continue button behaviour" do
  before { user_is_signed_in }

  # TODO: why is this something we need?
  context "when a task has a single step and the user answers it" do
    scenario "the user is returned to the same place in the task list " do
      start_journey_from_category(category: "long-text-question.json")
      click_first_link_in_section_list

      journey = Journey.last

      fill_in "answer[response]", with: "This is my long answer"

      click_continue

      expect(page.all("li.govuk-breadcrumbs__list-item").collect(&:text)).to eq \
        ["Dashboard", "Create Specification"]

      answer = LongTextAnswer.last

      expect(page).to have_current_path(journey_url(journey, anchor: answer.step.id))
    end
  end

  context "when a task has many steps" do
    scenario "the user is taken straight to the next step" do
      start_journey_from_category(category: "task-with-multiple-steps.json")
      click_first_link_in_section_list

      journey = Journey.last
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
  end

  context "when a task has not been started" do
    it "takes the user straight to the first step" do
      start_journey_from_category(category: "task-with-multiple-steps.json")

      click_first_link_in_section_list

      expect(page).not_to have_content "Task with multiple steps"
      expect(page).to have_content "Catering"
    end
  end
end
