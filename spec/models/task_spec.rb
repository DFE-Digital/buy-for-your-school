require "rails_helper"

RSpec.describe Task, type: :model do
  it { should belong_to(:section) }
  it { should have_many(:steps) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:contentful_id) }
  end

  describe "#visible_steps" do
    it "only returns steps which are not hidden" do
      task = create(:task)
      step_1 = create(:step, :radio, hidden: false, task: task)
      _step_2 = create(:step, :radio, hidden: true, task: task)

      expect(task.visible_steps).to eq [step_1]
    end
  end

  describe "#visible_steps_count" do
    it "returns the number of visible steps" do
      task = create(:task)
      create(:step, :radio, hidden: false, task: task)
      create(:step, :radio, hidden: true, task: task)

      expect(task.visible_steps_count).to eq 1
    end
  end

  describe "#has_single_visible_step?" do
    context "when the task has one visible step" do
      it "returns true" do
        task = create(:task)
        _step_1 = create(:step, :radio, hidden: false, task: task)
        _step_2 = create(:step, :radio, hidden: true, task: task)

        expect(task.has_single_visible_step?).to be true
      end
    end

    context "when the task has more than one visible step" do
      it "returns true" do
        task = create(:task)
        _step_1 = create(:step, :radio, hidden: false, task: task)
        _step_2 = create(:step, :radio, hidden: false, task: task)

        expect(task.has_single_visible_step?).to be false
      end
    end
  end

  describe "#answered_questions_count" do
    it "returns the number of visible questions which have been answered" do
      task = create(:task)

      step_1 = create(:step, :radio, hidden: false, task: task)
      create(:radio_answer, step: step_1)
      step_2 = create(:step, :radio, hidden: true, task: task)
      create(:radio_answer, step: step_2)

      create(:step, :radio, hidden: false, task: task)
      create(:step, :radio, hidden: true, task: task)

      expect(task.answered_questions_count).to eq 1
    end
  end

  describe "#status" do
    it "returns NOT_STARTED when no visible questions have been answered" do
      task = create(:task)
      create(:step, :radio, hidden: false, task: task)
      step_2 = create(:step, :radio, hidden: true, task: task)
      create(:radio_answer, step: step_2)

      expect(task.status).to eq Task::NOT_STARTED
    end

    it "returns IN_PROGRESS when some but not all visible questions have been answered" do
      task = create(:task)
      step_1 = create(:step, :radio, hidden: false, task: task)
      create(:radio_answer, step: step_1)
      step_2 = create(:step, :radio, hidden: true, task: task)
      create(:radio_answer, step: step_2)
      create(:step, :radio, hidden: true, task: task)
      create(:step, :radio, hidden: false, task: task)

      expect(task.status).to eq Task::IN_PROGRESS
    end

    it "returns COMPLETED when all visible questions have been answered" do
      task = create(:task)
      step_1 = create(:step, :radio, hidden: false, task: task)
      create(:radio_answer, step: step_1)
      step_2 = create(:step, :radio, hidden: true, task: task)
      create(:radio_answer, step: step_2)
      step_3 = create(:step, :radio, hidden: false, task: task)
      create(:radio_answer, step: step_3)
      create(:step, :radio, hidden: true, task: task)

      expect(task.status).to eq Task::COMPLETED
    end
  end

  describe "#all_steps_answered?" do
    it "returns true when all steps have answers" do
      task = create(:task)
      step = create(:step, :radio, task: task)
      _answer = create(:radio_answer, step: step)

      expect(task.all_steps_answered?).to eq(true)
    end

    it "returns false when no steps have answers" do
      task = create(:task)
      _step = create(:step, :radio, task: task)
      # Omit the creation of an answer

      expect(task.all_steps_answered?).to eq(false)
    end

    it "returns false when some steps have answers" do
      task = create(:task)

      step_1 = create(:step, :radio, task: task)
      _answer_1 = create(:radio_answer, step: step_1)

      _step_2 = create(:step, :radio, task: task)
      # Omit the creation of an answer for step 2

      expect(task.all_steps_answered?).to eq(false)
    end

    context "when there is a hidden step without an answer" do
      it "ignores it and returns true" do
        task = create(:task)
        _hidden_step = create(:step, :radio, task: task, hidden: true)

        expect(task.all_steps_answered?).to eq(true)
      end
    end
  end

  describe "#next_unanswered_step_id" do
    context "when no steps have answers" do
      it "returns the first step ID" do
        task = create(:task)

        step_1 = create(:step, :radio, task: task, order: 0)
        _step_2 = create(:step, :radio, task: task, order: 1)

        result = task.next_unanswered_step_id

        expect(result).to eq(step_1.id)
      end
    end

    context "when all steps have answers" do
      it "returns nil" do
        task = create(:task)

        step_1 = create(:step, :radio, task: task, order: 0)
        _answer_1 = create(:radio_answer, step: step_1)

        step_2 = create(:step, :radio, task: task, order: 1)
        _answer_2 = create(:radio_answer, step: step_2)

        result = task.next_unanswered_step_id

        expect(result).to eq(nil)
      end
    end

    context "when only the first step has been answered" do
      it "returns the second step ID" do
        task = create(:task)

        step_1 = create(:step, :radio, task: task, order: 0)
        _answer_1 = create(:radio_answer, step: step_1)

        step_2 = create(:step, :radio, task: task, order: 1)
        # Omit an answer for step 2

        result = task.next_unanswered_step_id

        expect(result).to eq(step_2.id)
      end
    end

    context "when a middle step has been answered" do
      it "returns the first step ID" do
        task = create(:task)

        step_1 = create(:step, :radio, task: task, order: 0)
        # Omit an answer for step 1

        step_2 = create(:step, :radio, task: task, order: 1)
        _answer_2 = create(:radio_answer, step: step_2)

        _step_3 = create(:step, :radio, task: task, order: 2)
        # Omit an answer for step 3

        result = task.next_unanswered_step_id

        expect(result).to eq(step_1.id)
      end
    end
  end

  describe "#visible_steps_with_answers" do
    it "returns all steps with answers" do
      task = create(:task)

      step_1 = create(:step, :radio, task: task, order: 0)
      # Omit an answer for step 1

      step_2 = create(:step, :radio, task: task, order: 1)
      _answer_2 = create(:radio_answer, step: step_2)

      result = task.visible_steps_with_answers

      expect(result).to include(step_2)
      expect(result).not_to include(step_1)
    end

    context "when there is a hidden step without an answer" do
      it "returns an empty array" do
        task = create(:task)

        _step = create(:step, :radio, task: task, order: 0, hidden: true)
        # Omit an answer for hidden step

        result = task.visible_steps_with_answers

        expect(result).to eq([])
      end
    end

    context "when there is a hidden step with an answer" do
      it "returns an empty array" do
        task = create(:task)

        step = create(:step, :radio, task: task, order: 0, hidden: true)
        _answer = create(:radio_answer, step: step)

        result = task.visible_steps_with_answers

        expect(result).to eq([])
      end
    end
  end
end
