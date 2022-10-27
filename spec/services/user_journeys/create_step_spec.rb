describe UserJourneys::CreateStep do
  subject(:service) { described_class }

  describe "#call" do
    let(:user_journey) { create(:user_journey) }

    it "creates a new user_journey_step with the given values" do
      user_journey_step = service.new(
        step_description: "step 1",
        product_section: "faf",
        user_journey_id: user_journey.id,
        session_id: "587466c1-0ec7-4a4a-a3f3-e6b8f20b2d7d",
      )
        .call

      expect(user_journey_step.step_description).to eq "step 1"
      expect(user_journey_step.product_section).to eq "faf"
      expect(user_journey_step.session_id).to eq "587466c1-0ec7-4a4a-a3f3-e6b8f20b2d7d"
      expect(user_journey_step.user_journey).to eq user_journey
    end
  end
end
