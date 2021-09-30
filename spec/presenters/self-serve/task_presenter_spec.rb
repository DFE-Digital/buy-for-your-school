require "rails_helper"

RSpec.describe TaskPresenter do
  describe "#step" do
    it "returns a decorated step" do
      task = create(:task, :with_steps)
      presenter = described_class.new(task)
      expect(presenter.step).to be_a StepPresenter
    end
  end

  describe "#one_step?" do
    context "when there is a single step" do
      it "returns true" do
        task = create(:task, :with_steps)
        presenter = described_class.new(task)
        expect(presenter.one_step?).to be true
      end
    end

    context "when there are many steps" do
      it "returns false" do
        task = create(:task, :with_steps, steps_count: 2)
        presenter = described_class.new(task)
        expect(presenter.one_step?).to be false
      end
    end
  end

  describe "#many_steps?" do
    context "when there are many steps" do
      it "returns true" do
        task = create(:task, :with_steps, steps_count: 2)
        presenter = described_class.new(task)
        expect(presenter.many_steps?).to be true
      end
    end

    context "when there is a single step" do
      it "returns false" do
        task = create(:task, :with_steps)
        presenter = described_class.new(task)
        expect(presenter.many_steps?).to be false
      end
    end
  end

  describe "#not_started?" do
    context "when no questions are answered" do
      it "returns true" do
        task = create(:task, :with_steps)
        presenter = described_class.new(task)
        expect(presenter.not_started?).to be true
      end
    end

    context "when some questions are answered" do
      it "returns false" do
        task = create(:task, :with_steps, steps_count: 2)
        create(:number_answer, step_id: task.steps.first.id)

        presenter = described_class.new(Task.find(task.id))
        expect(presenter.not_started?).to be false
      end
    end
  end

  describe "#in_progress?" do
    context "when some questions are answered" do
      it "returns true" do
        task = create(:task, :with_steps, steps_count: 2)
        create(:number_answer, step_id: task.steps.first.id)

        presenter = described_class.new(Task.find(task.id))
        expect(presenter.in_progress?).to be true
      end
    end

    context "when no questions are answered" do
      it "returns false" do
        task = create(:task, :with_steps)
        presenter = described_class.new(task)
        expect(presenter.in_progress?).to be false
      end
    end
  end

  describe "#completed?" do
    context "when all questions are answered" do
      it "returns true" do
        answer = create(:currency_answer)
        presenter = described_class.new(answer.step.task)
        expect(presenter.completed?).to be true
      end
    end

    context "when a question remains unanswered" do
      it "returns false" do
        task = create(:task, :with_steps)
        presenter = described_class.new(task)
        expect(presenter.completed?).to be false
      end
    end
  end

  describe "#status_id" do
    it "returns the uuid appended by status" do
      step = create(:step, :currency, contentful_model: "question")
      presenter = described_class.new(step)
      expect(presenter.status_id).to match(/[a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}-status/)
    end
  end
end
