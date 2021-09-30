RSpec.describe FlagStaleJourneys do
  subject(:service) { described_class.new }

  describe "#call" do
    context "with the default grace period" do
      context "when a journey is within the grace period" do
        it "is not flagged" do
          create(:journey, updated_at: 29.days.ago)

          expect(Journey.stale.count).to be_zero
          service.call
          expect(Journey.stale.count).to be_zero
        end
      end

      context "when a journey has passed the grace period" do
        it "is flagged" do
          create(:journey, updated_at: 31.days.ago)

          expect(Journey.stale.count).to be_zero
          service.call
          expect(Journey.stale.count).to be 1
        end
      end
    end

    context "with a custom grace period" do
      around do |example|
        ClimateControl.modify(DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR: "7") do
          example.run
        end
      end

      context "when a journey is within the grace period" do
        it "is not flagged" do
          create(:journey, updated_at: 6.days.ago)

          expect(Journey.stale.count).to be_zero
          service.call
          expect(Journey.stale.count).to be_zero
        end
      end

      context "when a journey has passed the grace period" do
        it "is flagged" do
          create(:journey, updated_at: 8.days.ago)

          expect(Journey.stale.count).to be_zero
          service.call
          expect(Journey.stale.count).to be 1
        end
      end
    end
  end
end
