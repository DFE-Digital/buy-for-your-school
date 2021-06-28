require "rails_helper"

RSpec.describe Journey, type: :model do
  it { is_expected.to have_many(:sections) }

  it "captures the category" do
    category = build(:category, :catering)
    journey = build(:journey, category: category)
    expect(journey.category.title).to eql("Catering")
  end

  describe "all_tasks_completed?" do
    context "when all steps have been completed" do
      it "returns true" do
        journey = create(:journey)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        step1 = create(:step, :radio, task: task)
        create(:radio_answer, step: step1)

        step2 = create(:step, :radio, task: task)
        create(:radio_answer, step: step2)

        expect(journey.all_tasks_completed?).to be true
      end
    end

    context "when no steps have been completed" do
      it "returns false " do
        journey = create(:journey)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        create_list(:step, 2, :radio, task: task)

        expect(journey.all_tasks_completed?).to be false
      end
    end

    context "when only some steps have been completed" do
      it "returns false" do
        journey = create(:journey)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        step = create(:step, :radio, task: task)
        create(:radio_answer, step: step)

        create(:step, :radio, task: task)
        # Omit answer for step 2

        expect(journey.all_tasks_completed?).to be false
      end
    end

    context "when there are uncompleted hidden steps" do
      it "ignores them and returns true" do
        journey = create(:journey)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        step = create(:step, :radio, task: task)
        create(:radio_answer, step: step)

        create(:step, :radio, task: task, hidden: true)
        # Omit answer for step 2

        expect(journey.all_tasks_completed?).to be true
      end
    end
  end

  describe "freshen!" do
    it "set started to true" do
      category = build(:category, :catering)
      journey = build(:journey, category: category)
      journey.freshen!
      expect(journey.reload.started).to eq(true)
    end

    it "sets the updated_at to now" do
      travel_to Time.zone.local(2004, 11, 24, 1, 4, 44)
      category = build(:category, :catering)
      journey = build(:journey, category: category)

      journey.freshen!

      expect(journey.updated_at).to eq(Time.zone.now)
    end

    context "when started is already true" do
      it "does not update the record" do
        category = build(:category, :catering)
        journey = build(:journey, category: category, started: true)
        expect(journey).not_to receive(:update).with(started: true)
        journey.freshen!
      end
    end
  end
end
