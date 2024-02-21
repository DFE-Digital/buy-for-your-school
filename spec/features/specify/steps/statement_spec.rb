RSpec.feature "Statements", flaky: true do
  before do
    start_journey_from_category(category: "statement.json")
  end

  it "can be acknowledged" do
    journey = Journey.last
    task = Task.find_by(title: "Task with a single statement step")
    step = task.steps.first

    visit journey_step_path(journey, step)

    expect(page).to have_content "statement-step.json title"
    expect(source).to include "<h4 id=\"heading-4\">Heading 4</h4>"
    expect(page).to have_button "Acknowledge!"

    click_on "Acknowledge!"

    expect(Task.find(task.id).statement_ids).to include(step.id)
  end

  # TODO: Statements should appear in the list of steps
  it do
    expect(page).not_to have_content "statement-step.json title"
  end
end
