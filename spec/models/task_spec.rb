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
end
