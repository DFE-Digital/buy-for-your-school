# TODO: do we mean "Completing" a step?
#
RSpec.feature "Beginning a step" do
  it "is logged" do
    start_journey_from_category(category: "radio-question.json")
    click_first_link_in_section_list

    step = Step.last
    logged_event = ActivityLogItem.last

    expect(logged_event.action).to eq "begin_step"
    expect(logged_event.journey_id).to eq Journey.last.id
    expect(logged_event.user_id).to eq User.last.id
    expect(logged_event.contentful_category_id).to eq "contentful-category-entry"
    expect(logged_event.contentful_section_id).to eq step.task.section.contentful_id
    expect(logged_event.contentful_task_id).to eq step.task.contentful_id
    expect(logged_event.contentful_step_id).to eq step.contentful_id
  end
end
