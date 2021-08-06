RSpec.feature "Contentful Entry Type: Markdown" do
  before { user_is_signed_in }

  context "when Contentful entry is of type 'markdown'" do
    scenario "the statement is not displayed in the task list" do
      # TODO: setup with factory
      start_journey_from_category(category: "statement.json")

      expect(page).not_to have_content("statement-step.json title")
    end

    scenario "the statement can be acknowledged" do
      # TODO: setup with factory
      start_journey_from_category(category: "statement.json")

      journey = Journey.last
      task = Task.find_by(title: "Task with a single statement step")
      step = task.steps.first

      visit journey_step_path(journey, step)

      expect(page).to have_content("statement-step.json title")
      expect(page.html).to include("<h4>Heading 4</h4>")
      expect(page).to have_button("Acknowledge!")

      click_on("Acknowledge!")

      expect(Task.find(task.id).statement_ids).to include(step.id)
    end
  end
end
