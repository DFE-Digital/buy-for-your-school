require "rails_helper"

RSpec.describe DeleteStaleJourneys do
  before { travel_to Time.zone.local(2021, 4, 8, 14, 24, 0) }

  after { travel_back }

  describe "#call" do
    it "destroys a journey and all associated records" do
      step = create(:step, :radio)
      journey = step.journey
      journey.update!(started: false, updated_at: (1.month + 1.day).ago)
      _radio_answer = create(:radio_answer, step: step)
      _short_text_answer = create(:short_text_answer, step: step)

      described_class.new.call

      expect(Journey.count).to eq(0)
      expect(Step.count).to eq(0)
      expect(RadioAnswer.count).to eq(0)
      expect(ShortTextAnswer.count).to eq(0)
    end

    it "only destroys journeys we think of as stale" do
      stale_journey = create(:journey, started: false, updated_at: 2.months.ago)

      about_to_become_stale_journey = create(:journey, started: false, updated_at: 1.month.ago)
      recently_created_journey = create(:journey, started: false, updated_at: 4.days.ago)
      recently_active_journey = create(:journey, started: true, updated_at: 4.days.ago)
      old_active_journey = create(:journey, started: true, updated_at: 2.months.ago)

      described_class.new.call

      remaining_journeys = Journey.all
      expect(remaining_journeys).not_to include(stale_journey)

      expect(remaining_journeys).to include(about_to_become_stale_journey)
      expect(remaining_journeys).to include(recently_created_journey)
      expect(remaining_journeys).to include(recently_active_journey)
      expect(remaining_journeys).to include(old_active_journey)
    end

    context "when the journey is marked as started" do
      it "is not destroyed regardless of updated_at" do
        legacy_journey_with_no_activity = create(:journey, started: true)
        old_journey_with_activity = create(:journey, started: true, updated_at: (1.month + 1.day).ago)
        recent_journey_with_activity = create(:journey, started: true, updated_at: (1.month - 1.day).ago)

        described_class.new.call

        remaining_journeys = Journey.all
        expect(remaining_journeys).to include(legacy_journey_with_no_activity)
        expect(remaining_journeys).to include(old_journey_with_activity)
        expect(remaining_journeys).to include(recent_journey_with_activity)
      end
    end

    context "when the journey is not marked as started" do
      context "and the journey hasn't been worked on for more than 1 month" do
        it "is destroyed" do
          journey = create(:journey, started: false, updated_at: (1.month + 1.day).ago)
          described_class.new.call
          expect { Journey.find(journey.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "and the journey has been worked on in the last 1 month" do
        it "is not destroyed" do
          journey = create(:journey, started: true, updated_at: (1.month - 1.day).ago)
          described_class.new.call
          expect(Journey.find(journey.id)).to eq(journey)
        end
      end

      context "and the journey has been worked on exactly 1 month ago" do
        it "is not destroyed" do
          journey = create(:journey, started: true, updated_at: 1.month.ago)
          described_class.new.call
          expect(Journey.find(journey.id)).to eq(journey)
        end
      end
    end

    context "when the environment variable DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR is set" do
      around do |example|
        ClimateControl.modify(
          DAYS_A_JOURNEY_CAN_BE_INACTIVE_FOR: "5",
        ) do
          example.run
        end
      end

      it "only deletes unstarted journeys that were last modified more than 5 days ago" do
        stale_journey = create(:journey, started: false, updated_at: 6.days.ago)
        about_to_become_stale_journey = create(:journey, started: false, updated_at: 5.days.ago)
        active_journey = create(:journey, started: false, updated_at: 4.days.ago)

        described_class.new.call

        remaining_journeys = Journey.all
        expect(remaining_journeys).not_to include(stale_journey)
        expect(remaining_journeys).to include(about_to_become_stale_journey)
        expect(remaining_journeys).to include(active_journey)
      end
    end
  end
end
