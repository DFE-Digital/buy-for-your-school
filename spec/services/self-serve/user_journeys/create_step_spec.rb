RSpec.describe UserJourneys::CreateStep do
  subject(:service) do
    described_class.new(
      step_description: "test_step",
      product_section: UserJourneyStep.product_sections[:faf],
      user_journey_id: user_journey.id,
      session_id: "297df2ed-edfd-482c-8bb4-200beb28160f",
    )
  end

  let(:user_journey) { create(:user_journey) }

  describe "#call" do
    it "creates a user journey step" do
      user_journey_step = service.call
      expect(user_journey_step.step_description).to eq "test_step"
      expect(user_journey_step.product_section).to eq "faf"
      expect(user_journey_step.user_journey_id).to eq user_journey.id
      expect(user_journey_step.session_id).to eq "297df2ed-edfd-482c-8bb4-200beb28160f"
    end
  end
end
