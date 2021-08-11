RSpec.feature "new journey" do
  let(:user) { create(:user) }
  let(:fixture) { "radio-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  context "when a new journey is begun" do
    scenario "records that action in the event log" do
      first_logged_event = ActivityLogItem.first

      # /journeys/302e58f4-01b3-469a-906e-db6991184699
      expect(page).to have_a_journey_path
      expect(first_logged_event.action).to eq("begin_journey")
      expect(first_logged_event.journey_id).to eq(Journey.last.id)
      expect(first_logged_event.user_id).to eq(User.last.id)
      expect(first_logged_event.contentful_category_id).to eq("contentful-category-entry")
    end
  end
end
