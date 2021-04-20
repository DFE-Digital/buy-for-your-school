require "rails_helper"

RSpec.describe Journey, type: :model do
  it { should have_many(:sections) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:liquid_template) }
  end

  it "captures the category" do
    journey = build(:journey, :catering)
    expect(journey.category).to eql("catering")
  end

  describe "all_steps_completed?" do
    context "when all steps have been completed" do
      it "returns true" do
        journey = create(:journey)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        step_1 = create(:step, :radio, task: task)
        create(:radio_answer, step: step_1)

        step_2 = create(:step, :radio, task: task)
        create(:radio_answer, step: step_2)

        expect(journey.all_steps_completed?).to be true
      end
    end

    context "when no steps have been completed" do
      it "returns false " do
        journey = create(:journey)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        create_list(:step, 2, :radio, task: task)

        expect(journey.all_steps_completed?).to be false
      end
    end

    context "when only some steps have been completed" do
      it "returns false" do
        journey = create(:journey)

        step_1 = create(:step, :radio)
        create(:radio_answer, step: step_1)

        create(:step, :radio)

        expect(journey.all_steps_completed?).to be false
      end
    end

    context "when there are uncompleted hidden steps" do
      it "ignores them and returns true" do
        journey = create(:journey)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        step_1 = create(:step, :radio, task: task)
        create(:radio_answer, step: step_1)

        _hidden_step_without_an_answer = create(:step, :radio, hidden: true)

        expect(journey.all_steps_completed?).to be true
      end
    end
  end

  describe "freshen!" do
    it "set started to true" do
      journey = build(:journey, :catering)
      journey.freshen!
      expect(journey.reload.started).to eq(true)
    end

    it "sets the last_worked_on to now" do
      travel_to Time.zone.local(2004, 11, 24, 1, 4, 44)
      journey = build(:journey, :catering)

      journey.freshen!

      expect(journey.last_worked_on).to eq(Time.zone.now)
    end

    context "when started is already true" do
      it "does not update the record" do
        journey = build(:journey, :catering, started: true)
        expect(journey).not_to receive(:update).with(started: true)
        journey.freshen!
      end
    end
  end
end
