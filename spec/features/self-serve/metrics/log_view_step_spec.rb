RSpec.feature "Revising an answered question" do
  it "is logged" do
    start_journey_from_category(category: "radio-question.json")

    journey = Journey.last
    task = Task.find_by(title: "Radio task")
    step = task.steps.first
    create(:radio_answer, step:)

    visit edit_journey_step_path(journey, step)

    logged_event = ActivityLogItem.last

    expect(logged_event.action).to eq "view_step"
    expect(logged_event.journey_id).to eq journey.id
    expect(logged_event.user_id).to eq User.last.id
    expect(logged_event.contentful_category_id).to eq "contentful-category-entry"
    expect(logged_event.contentful_section_id).to eq step.task.section.contentful_id
    expect(logged_event.contentful_task_id).to eq step.task.contentful_id
    expect(logged_event.contentful_step_id).to eq step.contentful_id
  end
end
