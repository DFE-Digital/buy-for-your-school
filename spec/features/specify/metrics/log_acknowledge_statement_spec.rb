RSpec.feature "A step is answered with no user input" do
  let(:user) { create(:user) }
  let(:category) { create(:category, :catering, contentful_id: "contentful-category-entry") }
  let(:journey) { create(:journey, user:, category:) }
  let(:section) { create(:section, title: "Section A", journey:, contentful_id: "statement-section") }

  it "is logged" do
    statement_task = create(:task, title: "Task with a single statement step", section:)
    create(:step, :statement, title: "statement-step.json title", task: statement_task)

    user_is_signed_in(user:)
    visit "/journeys/#{journey.id}"

    within(".app-task-list") do
      click_on "Task with a single statement"
    end

    # Continue button logs acknowledge_statement, update_answer and view_journey successively
    click_continue
    journey = Journey.last

    statement_task_logged_event = ActivityLogItem.where(action: "acknowledge_statement").first
    expect(statement_task_logged_event.journey_id).to eq(journey.id)
    expect(statement_task_logged_event.user_id).to eq(user.id)
    expect(statement_task_logged_event.contentful_category_id).to eq "contentful-category-entry"
    expect(statement_task_logged_event.contentful_section_id).to eq "statement-section"
    expect(statement_task_logged_event.contentful_task_id).to eq(statement_task.contentful_id)
  end
end
