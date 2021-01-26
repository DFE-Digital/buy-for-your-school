require "rails_helper"

RSpec.describe Journey, type: :model do
  it { should have_many(:steps) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:liquid_template) }
  end

  it "captures the category" do
    journey = build(:journey, :catering)
    expect(journey.category).to eql("catering")
  end

  describe "all_tasks_completed?" do
    it "returns true when all tasks have been completed" do
      journey = create(:journey)

      step_1 = create(:step, :radio, journey: journey)
      create(:radio_answer, step: step_1)

      step_2 = create(:step, :radio, journey: journey)
      create(:radio_answer, step: step_2)

      expect(journey.all_tasks_completed?).to be true
    end

    it "returns false when no tasks have been completed" do
      journey = create(:journey)

      create(:step, :radio, journey: journey)

      create(:step, :radio, journey: journey)

      expect(journey.all_tasks_completed?).to be false
    end

    it "returns false when only some tasks have been completed" do
      journey = create(:journey)

      step_1 = create(:step, :radio, journey: journey)
      create(:radio_answer, step: step_1)

      create(:step, :radio, journey: journey)

      expect(journey.all_tasks_completed?).to be false
    end
  end
end
