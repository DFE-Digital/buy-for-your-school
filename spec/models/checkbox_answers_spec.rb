require "rails_helper"

RSpec.describe CheckboxAnswers, type: :model do
  it "should belong_to a step" do
    association = described_class.reflect_on_association(:step)
    expect(association.macro).to eq(:belongs_to)
  end

  describe "#response" do
    it "returns an array of strings" do
      answer = build(:checkbox_answers, response: ["Blue", "Green"])
      expect(answer.response).to eq(["Blue", "Green"])
    end
  end

  describe "validations" do
    it "is not valid if there is no response" do
      answer = build(:checkbox_answers, response: [])
      expect(answer).not_to be_valid
    end

    context "when the step is skippable" do
      it "does not validate the presence of the response" do
        skippable_step = create(:step, :checkbox_answers, skip_call_to_action_text: "None of the above")
        answer = build(:checkbox_answers, step: skippable_step, response: "", skipped: true)

        answer.save

        expect(answer.persisted?).to be true
      end
    end
  end

  describe "#response=" do
    context "when the response only includes blank items" do
      it "should be invalid" do
        answer = build(:checkbox_answers, response: ["", ""])
        expect(answer.valid?).to eq(false)
      end
    end

    context "when the response a mix of present and blank items" do
      it "should only store the present values" do
        answer = build(:checkbox_answers, response: ["Foo", ""])
        expect(answer.response).to eq(["Foo"])
      end
    end
  end

  describe "#update_task_counters" do
    it "increments the task tally via callback" do
      task = create(:task)
      expect(task.step_tally["answered"]).to eq 0

      step_1 = create(:step, :checkbox_answers, hidden: false, task: task)
      answer_1 = create(:checkbox_answers, step: step_1)

      expect(task.step_tally["answered"]).to eq 1

      answer_1.destroy

      expect(task.step_tally["answered"]).to eq 0
    end
  end
end
