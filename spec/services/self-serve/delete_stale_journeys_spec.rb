RSpec.describe DeleteStaleJourneys do
  subject(:service) { described_class.new }

  describe "#call" do
    context "when a journey flagged as stale is within the grace period" do
      it "is not destroyed" do
        create(:journey, state: :stale, updated_at: 29.days.ago)

        expect(Journey.count).to be 1
        service.call
        expect(Journey.count).to be 1
      end
    end

    context "when a journey not flagged as stale has passed the grace period" do
      context "and has not been started" do
        it "is not destroyed" do
          create(:journey, state: :initial, updated_at: 31.days.ago)

          expect(Journey.count).to be 1
          service.call
          expect(Journey.count).to be 1
        end
      end
    end

    context "when a journey flagged as stale has passed the grace period" do
      context "and has been started" do
        it "is not destroyed" do
          create(:journey, state: :stale, started: true, updated_at: 31.days.ago)

          expect(Journey.count).to be 1
          service.call
          expect(Journey.count).to be 1
        end
      end

      it "is destroyed with all associated records" do
        step = create(:step, :radio)
        step.journey.update!(state: :stale, updated_at: 31.days.ago)
        create(:radio_answer, step:)

        expect(Journey.count).to be 1
        expect(Section.count).to be 1
        expect(Task.count).to be 1
        expect(Step.count).to be 1
        expect(RadioAnswer.count).to be 1

        service.call

        expect(Journey.count).to be_zero
        expect(Section.count).to be_zero
        expect(Task.count).to be_zero
        expect(Step.count).to be_zero
        expect(RadioAnswer.count).to be_zero
      end
    end
  end
end
