describe UserJourneys::Create do
  subject(:service) { described_class }

  describe "#call" do
    it "creates a new user_journey with the given referral_campaign and default status of 'in_progress'" do
      user_journey = service.new(referral_campaign: "test_campaign").call

      expect(user_journey.status).to eq "in_progress"
      expect(user_journey.referral_campaign).to eq "test_campaign"
    end
  end
end
