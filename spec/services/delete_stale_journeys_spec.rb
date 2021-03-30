require "rails_helper"

RSpec.describe DeleteStaleJourneys do
  describe "#call" do
    it "destroys a journey and all associated records" do
      journey = create(:journey, started: false, last_worked_on: 1.month.ago + 1.day)
      step = create(:step, :radio, journey: journey)
      _radio_answer = create(:radio_answer, step: step)
      _short_text_answer = create(:short_text_answer, step: step)

      DeleteStaleJourneys.new.call

      expect(Journey.count).to eq(0)
      expect(Step.count).to eq(0)
      expect(RadioAnswer.count).to eq(0)
      expect(ShortTextAnswer.count).to eq(0)
    end

    context "when the journey is marked as started" do
      it "is not destroyed" do
        legacy_journey_with_no_activity = create(:journey, started: true, last_worked_on: nil)
        old_journey_with_activity = create(:journey, started: true, last_worked_on: 1.month.ago + 1.day)
        recent_journey_with_activity = create(:journey, started: true, last_worked_on: 1.month.ago - 1.day)

        DeleteStaleJourneys.new.call

        remaining_journeys = Journey.all
        expect(remaining_journeys).to include(legacy_journey_with_no_activity)
        expect(remaining_journeys).to include(old_journey_with_activity)
        expect(remaining_journeys).to include(recent_journey_with_activity)
      end
    end

    context "when the journey is not marked as started" do
      context "and the journey hasn't been worked on for more than 1 month" do
        it "is destroyed" do
          journey = create(:journey, started: false, last_worked_on: 1.month.ago + 1.day)
          DeleteStaleJourneys.new.call
          expect { Journey.find(journey.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "and the journey has been worked on in the last 1 month" do
        it "is not destroyed" do
          journey = create(:journey, started: true, last_worked_on: 1.month.ago - 1.day)
          DeleteStaleJourneys.new.call
          expect(Journey.find(journey.id)).to eq(journey)
        end
      end

      context "and the journey has been worked on exactly 1 month ago" do
        it "is not destroyed" do
          journey = create(:journey, started: true, last_worked_on: 1.month.ago)
          DeleteStaleJourneys.new.call
          expect(Journey.find(journey.id)).to eq(journey)
        end
      end
    end
  end
end
