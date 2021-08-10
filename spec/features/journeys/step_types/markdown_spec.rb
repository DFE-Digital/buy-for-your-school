RSpec.feature "markdown" do
  let(:user) { create(:user) }
  let(:fixture) { "statement.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  context "when the step is of type markdown" do
    scenario "the statement is not displayed in the task list" do
      # /journeys/302e58f4-01b3-469a-906e-db6991184699
      expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
      expect(page).not_to have_content("statement-step.json title")
    end

    scenario "the statement can be acknowledged" do
      journey = Journey.last
      task = Task.find_by(title: "Task with a single statement step")
      step = task.steps.first

      visit journey_step_path(journey, step)

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
      expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
      expect(find("h1.govuk-heading-xl")).to have_text "statement-step.json title"
      within("div.govuk-body") do
        expect(page.html).to include("<h4>Heading 4</h4>")
      end
      expect(page).to have_button("Acknowledge!")
      click_on("Acknowledge!")
      expect(Task.find(task.id).statement_ids).to include(step.id)
    end
  end
end
