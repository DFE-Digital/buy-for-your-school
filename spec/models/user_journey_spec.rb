describe UserJourney, type: :model do
  subject(:user_journey) { described_class }

  describe "#by_session_id" do
    let(:session_id) { "587466c1-0ec7-4a4a-a3f3-e6b8f20b2d7d" }
    let!(:user_journey_1) { create(:user_journey) }
    let!(:user_journey_2) { create(:user_journey) }
    let!(:user_journey_3) { create(:user_journey) }

    before do
      create(:user_journey_step, user_journey: user_journey_1, session_id:)
      create(:user_journey_step, user_journey: user_journey_2, session_id:)
      create(:user_journey_step, user_journey: user_journey_3, session_id: "7daef9bb-c376-4f3b-ae5b-cdebaa12fd65")
    end

    it "returns all user journeys that have steps with the given session_id" do
      expect(user_journey.by_session_id(session_id)).to contain_exactly(user_journey_1, user_journey_2)
    end
  end
end
