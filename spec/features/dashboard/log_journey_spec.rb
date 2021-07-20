RSpec.feature "Log when a journey is viewed" do
  let(:user) { create(:user) }
  let(:journey) { create(:journey, user: user) }

  before do
    user_is_signed_in(user: user)
    visit "/dashboard"
  end

  # @see RecordAction
  context "when a user revisits an existing journey" do
    it "is recorded in the event log" do
      visit_journey

      last_logged_event = ActivityLogItem.last
      expect(last_logged_event.action).to eq("view_journey")
      expect(last_logged_event.journey_id).to eq(journey.id)
      expect(last_logged_event.user_id).to eq(user.id)
      expect(last_logged_event.contentful_category_id).to eq("12345678")
    end
  end
end
