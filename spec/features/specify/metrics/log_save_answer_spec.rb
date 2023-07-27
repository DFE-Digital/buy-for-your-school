RSpec.feature "Answering a question" do
  it "is logged" do
    start_journey_from_category(category: "long-text-question.json")
    click_first_link_in_section_list

    journey = Journey.last

    fill_in "answer[response]", with: "This is my long answer"

    click_continue

    logged_event = ActivityLogItem.where(action: "save_answer").first

    expect(logged_event.journey_id).to eq journey.id
    expect(logged_event.user_id).to eq User.last.id
    expect(logged_event.contentful_category_id).to eq "contentful-category-entry"
    expect(logged_event.contentful_section_id).to eq Section.last.contentful_id
    expect(logged_event.contentful_task_id).to eq Task.last.contentful_id
    expect(logged_event.contentful_step_id).to eq Step.last.contentful_id
    expect(logged_event.data["success"]).to be true
  end
end
