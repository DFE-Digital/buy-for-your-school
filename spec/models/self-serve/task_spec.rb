RSpec.describe Task, type: :model do
  it { is_expected.to belong_to(:section) }
  it { is_expected.to have_many(:steps) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:contentful_id) }
  end

  describe "#has_single_visible_step?" do
    context "when the task has one visible step" do
      it "returns true" do
        task = create(:task)
        create(:step, :radio, hidden: false, task:)
        create(:step, :radio, hidden: true, task:)

        expect(task.has_single_visible_step?).to be true
      end
    end

    context "when the task has more than one visible step" do
      it "returns true" do
        task = create(:task)
        create(:step, :radio, hidden: false, task:)
        create(:step, :radio, hidden: false, task:)

        expect(task.has_single_visible_step?).to be false
      end
    end
  end

  describe "#step_tally" do
    let(:task) { create(:task) }

    it "returns a hash of counted steps in different states" do
      expect(task.step_tally["visible"]).to eq 0
      expect(task.step_tally["completed"]).to eq 0
      expect(task.step_tally["total"]).to eq 0
      expect(task.step_tally["hidden"]).to eq 0
      expect(task.step_tally["statements"]).to eq 0
      expect(task.step_tally["questions"]).to eq 0
    end

    it "increments as steps are added" do
      create(:step, :currency, hidden: false, task:)
      expect(task.step_tally["hidden"]).to eq 0
      expect(task.step_tally["visible"]).to eq 1
      expect(task.step_tally["total"]).to eq 1

      create(:step, :number, hidden: true, task:)
      expect(task.step_tally["visible"]).to eq 1
      expect(task.step_tally["hidden"]).to eq 1
      expect(task.step_tally["total"]).to eq 2
    end

    it "updates as steps are edited" do
      step1 = create(:step, :currency, hidden: true, task:)
      step2 = create(:step, :number, hidden: true, task:)

      expect(task.step_tally["hidden"]).to eq 2
      step1.update!(hidden: false)
      expect(task.step_tally["hidden"]).to eq 1
      step2.update!(hidden: false)
      expect(task.step_tally["hidden"]).to eq 0
    end

    it "counts how many questions are answered" do
      create(:step, :radio, hidden: true, task:)
      step = create(:step, :radio, hidden: false, task:)
      answer = create(:radio_answer, step:)

      expect(task.step_tally["answered"]).to eq 1
      expect(task.step_tally["completed"]).to eq 1
      answer.destroy!
      expect(task.step_tally["answered"]).to eq 0
      expect(task.step_tally["completed"]).to eq 0
    end

    it "counts how many statements are acknowledged" do
      create(:step, :statement, hidden: true, task:)
      statement = create(:step, :statement, hidden: false, task:)

      expect(task.step_tally["acknowledged"]).to eq 0
      expect(task.step_tally["completed"]).to eq 0

      statement.acknowledge!

      expect(task.step_tally["acknowledged"]).to eq 1
      expect(task.step_tally["completed"]).to eq 1
    end
  end

  describe "#status" do
    it "returns NOT_STARTED when no visible questions have been answered" do
      task = create(:task)
      create(:step, :radio, hidden: false, task:)
      # Omit answer for step 1

      step = create(:step, :radio, hidden: true, task:)
      create(:radio_answer, step:)

      expect(task.status).to eq Task::NOT_STARTED
    end

    it "returns IN_PROGRESS when some but not all visible questions have been answered" do
      task = create(:task)
      visible_step = create(:step, :radio, hidden: false, task:)
      create(:radio_answer, step: visible_step)
      hidden_step = create(:step, :radio, hidden: true, task:)
      create(:radio_answer, step: hidden_step)
      create(:step, :radio, hidden: true, task:)
      create(:step, :radio, hidden: false, task:)

      expect(task.status).to eq Task::IN_PROGRESS
    end

    it "returns COMPLETED when all visible questions have been answered" do
      task = create(:task)
      visible_step1 = create(:step, :radio, hidden: false, task:)
      create(:radio_answer, step: visible_step1)
      hidden_step = create(:step, :radio, hidden: true, task:)
      create(:radio_answer, step: hidden_step)
      visible_step2 = create(:step, :radio, hidden: false, task:)
      create(:radio_answer, step: visible_step2)
      create(:step, :radio, hidden: true, task:)

      expect(task.status).to eq Task::COMPLETED
    end
  end

  describe "#all_statements_acknowledged?" do
    let(:task) { create(:task) }

    it "returns true when all steps have been acknowledged" do
      statement = create(:step, :statement, task:)

      expect(task.all_statements_acknowledged?).to be(false)

      statement.acknowledge!

      expect(task.all_statements_acknowledged?).to be(true)
    end
  end

  describe "#all_questions_answered?" do
    let(:task) { create(:task) }

    it "returns true when all questions have answers" do
      step = create(:step, :radio, task:)
      create(:radio_answer, step:)

      expect(task.all_questions_answered?).to be(true)
    end

    it "returns false when no questions have answers" do
      create(:step, :radio, task:)
      # Omit answer

      expect(task.all_questions_answered?).to be(false)
    end

    it "returns false when some questions have answers" do
      step = create(:step, :radio, task:)
      create(:radio_answer, step:)

      create(:step, :radio, task:)
      # Omit answer for step 2

      expect(task.all_questions_answered?).to be(false)
    end

    context "when there is a hidden question without an answer" do
      it "ignores it and returns true" do
        create(:step, :radio, task:, hidden: true)

        expect(task.all_questions_answered?).to be(true)
      end
    end
  end

  describe "#incomplete?" do
    # TODO: pull subject to the top of the spec
    let(:task) { create(:task) }

    it "returns true if some steps are not complete" do
      question = create(:step, :radio, task:)
      statement = create(:step, :statement, task:)

      expect(task.incomplete?).to be true

      create(:radio_answer, step: question)
      statement.acknowledge!

      expect(task.incomplete?).to be false
    end
  end

  describe "#all_steps_completed?" do
    let(:task) { create(:task) }

    it "returns true if all questions have been answered and statements acknowledged" do
      question = create(:step, :radio, task:)
      statement = create(:step, :statement, task:)

      expect(task.all_steps_completed?).to be false

      create(:radio_answer, step: question)
      statement.acknowledge!

      expect(task.all_steps_completed?).to be true
    end
  end

  describe "#visible_questions_with_answers" do
    it "returns all steps with answers" do
      task = create(:task)

      step1 = create(:step, :radio, task:, order: 0)
      # Omit answer for step 1

      step2 = create(:step, :radio, task:, order: 1)
      create(:radio_answer, step: step2)

      result = task.visible_questions_with_answers

      expect(result).to include(step2)
      expect(result).not_to include(step1)
    end

    context "when there is a hidden step without an answer" do
      it "returns an empty array" do
        task = create(:task)

        create(:step, :radio, task:, order: 0, hidden: true)
        # Omit answer for hidden step

        result = task.visible_questions_with_answers

        expect(result).to eq([])
      end
    end

    context "when there is a hidden step with an answer" do
      it "returns an empty array" do
        task = create(:task)

        step = create(:step, :radio, task:, order: 0, hidden: true)
        create(:radio_answer, step:)

        result = task.visible_questions_with_answers

        expect(result).to eq([])
      end
    end
  end

  describe "#all_unanswered_questions_skipped?" do
    let(:task) { create(:task) }

    it "returns true when all unanswered questions have been skipped" do
      number_step = create(:step, :number, task:)
      radio_step = create(:step, :radio, task:)

      expect(task.all_unanswered_questions_skipped?).to be false

      task.skipped_ids << number_step.id << radio_step.id
      task.save!

      expect(task.all_unanswered_questions_skipped?).to be true
    end
  end

  describe "#next_skipped_id" do
    let(:task) { create(:task) }

    it "returns the next ID in the array relative to the current one" do
      task.skipped_ids << "1" << "2" << "3"

      expect(task.next_skipped_id("1")).to eq "2"
      expect(task.next_skipped_id("2")).to eq "3"
      expect(task.next_skipped_id("3")).to eq "1"
    end

    it "returns nil if there is only one skipped question" do
      task.skipped_ids << "1"
      expect(task.next_skipped_id("1")).to be nil
    end
  end
end
