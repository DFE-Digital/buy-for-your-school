RSpec.describe Task, "#next_incomplete_step_id", type: :model do
  context "when no steps have answers" do
    it "returns the first step ID" do
      task = create(:task)

      step = create(:step, :radio, task:, order: 0)
      create(:step, :radio, task:, order: 1)

      result = task.next_incomplete_step_id

      expect(result).to eq(step.id)
    end
  end

  context "when all steps have answers" do
    it "returns nil" do
      task = create(:task)

      step1 = create(:step, :radio, task:, order: 0)
      create(:radio_answer, step: step1)

      step2 = create(:step, :radio, task:, order: 1)
      create(:radio_answer, step: step2)

      result = task.next_incomplete_step_id

      expect(result).to eq(nil)
    end
  end

  context "when only the first step has been answered" do
    it "returns the second step ID" do
      task = create(:task)

      step1 = create(:step, :radio, task:, order: 0)
      create(:radio_answer, step: step1)

      step2 = create(:step, :radio, task:, order: 1)
      # Omit answer for step 2

      result = task.next_incomplete_step_id

      expect(result).to eq(step2.id)
    end
  end

  context "when a middle step has been answered" do
    it "returns the first step ID" do
      task = create(:task)

      step1 = create(:step, :radio, task:, order: 0)
      # Omit answer for step 1

      step2 = create(:step, :radio, task:, order: 1)
      create(:radio_answer, step: step2)

      create(:step, :radio, task:, order: 2)
      # Omit answer for step 3

      result = task.next_incomplete_step_id

      expect(result).to eq(step1.id)
    end
  end
end
