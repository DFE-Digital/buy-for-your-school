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
end
