require "rails_helper"

RSpec.describe RadioAnswer, type: :model do
  it { should belong_to(:step) }

  it "captures the users response as a string" do
    answer = build(:radio_answer, response: "Yellow")
    expect(answer.response).to eql("Yellow")
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:response) }
  end

  describe "#update_task_counters" do
    it "increments the task tally via callback" do
      task = create(:task)
      expect(task.step_tally["answered"]).to eq 0

      step_1 = create(:step, :radio, hidden: false, task: task)
      answer_1 = create(:radio_answer, step: step_1)

      expect(task.step_tally["answered"]).to eq 1

      answer_1.destroy

      expect(task.step_tally["answered"]).to eq 0
    end
  end
end
