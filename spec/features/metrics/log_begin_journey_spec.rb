RSpec.feature "Beginning a journey" do
  it "is logged" do
    start_journey_from_category(category: "radio-question.json")

    logged_event = ActivityLogItem.first

    expect(logged_event.action).to eq "begin_journey"
    expect(logged_event.journey_id).to eq Journey.last.id
    expect(logged_event.user_id).to eq User.last.id
    expect(logged_event.contentful_category_id).to eq "contentful-category-entry"
  end
end
