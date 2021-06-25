require "rails_helper"

RSpec.describe Task, type: :model do
  it { is_expected.to belong_to(:section) }
  it { is_expected.to have_many(:steps) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:contentful_id) }
  end

  describe "#visible_steps" do
    it "only returns steps which are not hidden" do
      task = create(:task)
      step = create(:step, :radio, hidden: false, task: task)
      create(:step, :radio, hidden: true, task: task)

      expect(task.visible_steps).to eq [step]
    end
  end

  describe "#has_single_visible_step?" do
    context "when the task has one visible step" do
      it "returns true" do
        task = create(:task)
        create(:step, :radio, hidden: false, task: task)
        create(:step, :radio, hidden: true, task: task)

        expect(task.has_single_visible_step?).to be true
      end
    end

    context "when the task has more than one visible step" do
      it "returns true" do
        task = create(:task)
        create(:step, :radio, hidden: false, task: task)
        create(:step, :radio, hidden: false, task: task)

        expect(task.has_single_visible_step?).to be false
      end
    end
  end

  describe "#step_tally" do
    let(:task) { create(:task) }

    it "returns a hash of counted steps in different states" do
      expect(task.step_tally["visible"]).to eq 0
      expect(task.step_tally["answered"]).to eq 0
      expect(task.step_tally["total"]).to eq 0
      expect(task.step_tally["hidden"]).to eq 0
    end

    it "increments as steps are added" do
      create(:step, :currency, hidden: false, task: task)
      expect(task.step_tally["hidden"]).to eq 0
      expect(task.step_tally["visible"]).to eq 1
      expect(task.step_tally["total"]).to eq 1

      create(:step, :number, hidden: true, task: task)
      expect(task.step_tally["visible"]).to eq 1
      expect(task.step_tally["hidden"]).to eq 1
      expect(task.step_tally["total"]).to eq 2
    end

    it "updates as steps are edited" do
      step1 = create(:step, :currency, hidden: true, task: task)
      step2 = create(:step, :number, hidden: true, task: task)

      expect(task.step_tally["hidden"]).to eq 2
      step1.update!(hidden: false)
      expect(task.step_tally["hidden"]).to eq 1
      step2.update!(hidden: false)
      expect(task.step_tally["hidden"]).to eq 0
    end

    it "counts how many are answered" do
      create(:step, :radio, hidden: true, task: task)
      step = create(:step, :radio, hidden: false, task: task)
      answer = create(:radio_answer, step: step)

      expect(task.step_tally["answered"]).to eq 1
      answer.destroy!
      expect(task.step_tally["answered"]).to eq 0
    end
  end

  describe "#status" do
    it "returns NOT_STARTED when no visible questions have been answered" do
      task = create(:task)
      create(:step, :radio, hidden: false, task: task)
      # Omit answer for step 1

      step = create(:step, :radio, hidden: true, task: task)
      create(:radio_answer, step: step)

      expect(task.status).to eq Task::NOT_STARTED
    end

    it "returns IN_PROGRESS when some but not all visible questions have been answered" do
      task = create(:task)
      visible_step = create(:step, :radio, hidden: false, task: task)
      create(:radio_answer, step: visible_step)
      hidden_step = create(:step, :radio, hidden: true, task: task)
      create(:radio_answer, step: hidden_step)
      create(:step, :radio, hidden: true, task: task)
      create(:step, :radio, hidden: false, task: task)

      expect(task.status).to eq Task::IN_PROGRESS
    end

    it "returns COMPLETED when all visible questions have been answered" do
      task = create(:task)
      visible_step1 = create(:step, :radio, hidden: false, task: task)
      create(:radio_answer, step: visible_step1)
      hidden_step = create(:step, :radio, hidden: true, task: task)
      create(:radio_answer, step: hidden_step)
      visible_step2 = create(:step, :radio, hidden: false, task: task)
      create(:radio_answer, step: visible_step2)
      create(:step, :radio, hidden: true, task: task)

      expect(task.status).to eq Task::COMPLETED
    end
  end

  describe "#all_steps_answered?" do
    it "returns true when all steps have answers" do
      task = create(:task)
      step = create(:step, :radio, task: task)
      create(:radio_answer, step: step)

      expect(task.all_steps_answered?).to be(true)
    end

    it "returns false when no steps have answers" do
      task = create(:task)
      create(:step, :radio, task: task)
      # Omit answer

      expect(task.all_steps_answered?).to eq(false)
    end

    it "returns false when some steps have answers" do
      task = create(:task)

      step = create(:step, :radio, task: task)
      create(:radio_answer, step: step)

      create(:step, :radio, task: task)
      # Omit answer for step 2

      expect(task.all_steps_answered?).to eq(false)
    end

    context "when there is a hidden step without an answer" do
      it "ignores it and returns true" do
        task = create(:task)
        create(:step, :radio, task: task, hidden: true)

        expect(task.all_steps_answered?).to eq(true)
      end
    end
  end

  describe "#next_unanswered_step_id" do
    context "when no steps have answers" do
      it "returns the first step ID" do
        task = create(:task)

        step = create(:step, :radio, task: task, order: 0)
        create(:step, :radio, task: task, order: 1)

        result = task.next_unanswered_step_id

        expect(result).to eq(step.id)
      end
    end

    context "when all steps have answers" do
      it "returns nil" do
        task = create(:task)

        step1 = create(:step, :radio, task: task, order: 0)
        create(:radio_answer, step: step1)

        step2 = create(:step, :radio, task: task, order: 1)
        create(:radio_answer, step: step2)

        result = task.next_unanswered_step_id

        expect(result).to eq(nil)
      end
    end

    context "when only the first step has been answered" do
      it "returns the second step ID" do
        task = create(:task)

        step1 = create(:step, :radio, task: task, order: 0)
        create(:radio_answer, step: step1)

        step2 = create(:step, :radio, task: task, order: 1)
        # Omit answer for step 2

        result = task.next_unanswered_step_id

        expect(result).to eq(step2.id)
      end
    end

    context "when a middle step has been answered" do
      it "returns the first step ID" do
        task = create(:task)

        step1 = create(:step, :radio, task: task, order: 0)
        # Omit answer for step 1

        step2 = create(:step, :radio, task: task, order: 1)
        create(:radio_answer, step: step2)

        create(:step, :radio, task: task, order: 2)
        # Omit answer for step 3

        result = task.next_unanswered_step_id

        expect(result).to eq(step1.id)
      end
    end
  end

  describe "#visible_steps_with_answers" do
    it "returns all steps with answers" do
      task = create(:task)

      step1 = create(:step, :radio, task: task, order: 0)
      # Omit answer for step 1

      step2 = create(:step, :radio, task: task, order: 1)
      create(:radio_answer, step: step2)

      result = task.visible_steps_with_answers

      expect(result).to include(step2)
      expect(result).not_to include(step1)
    end

    context "when there is a hidden step without an answer" do
      it "returns an empty array" do
        task = create(:task)

        create(:step, :radio, task: task, order: 0, hidden: true)
        # Omit answer for hidden step

        result = task.visible_steps_with_answers

        expect(result).to eq([])
      end
    end

    context "when there is a hidden step with an answer" do
      it "returns an empty array" do
        task = create(:task)

        step = create(:step, :radio, task: task, order: 0, hidden: true)
        create(:radio_answer, step: step)

        result = task.visible_steps_with_answers

        expect(result).to eq([])
      end
    end
  end
end
