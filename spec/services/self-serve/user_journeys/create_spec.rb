RSpec.describe UserJourneys::Create do
  subject(:service) { described_class.new(referral_campaign: "test_campaign") }

  describe "#call" do
    it "creates a user journey with a default status of 'in progress'" do
      user_journey = service.call
      expect(user_journey.referral_campaign).to eq "test_campaign"
      expect(user_journey.status).to eq "in_progress"
    end
  end
end
