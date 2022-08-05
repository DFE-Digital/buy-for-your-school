RSpec.describe Journey, "#all_tasks_completed?", type: :model do
  subject(:journey) { build(:journey, category:) }

  let(:category) { build(:category) }
  let(:section) { create(:section, journey:) }
  let(:task) { create(:task, section:) }

  context "when all steps have been completed" do
    it "returns true" do
      step_1 = create(:step, :radio, task:)
      create(:radio_answer, step: step_1)

      step_2 = create(:step, :radio, task:)
      create(:radio_answer, step: step_2)

      expect(journey.all_tasks_completed?).to be true
    end
  end

  context "when no steps have been completed" do
    it "returns false " do
      create_list(:step, 2, :radio, task:)

      expect(journey.all_tasks_completed?).to be false
    end
  end

  context "when only some steps have been completed" do
    it "returns false" do
      step = create(:step, :radio, task:)
      create(:radio_answer, step:)

      create(:step, :radio, task:)
      # Omit answer for step 2

      expect(journey.all_tasks_completed?).to be false
    end
  end

  context "when there are uncompleted hidden steps" do
    it "ignores them and returns true" do
      step = create(:step, :radio, task:)
      create(:radio_answer, step:)

      create(:step, :radio, task:, hidden: true)
      # Omit answer for step 2

      expect(journey.all_tasks_completed?).to be true
    end
  end
end
