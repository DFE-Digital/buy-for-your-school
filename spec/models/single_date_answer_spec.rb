require "rails_helper"

RSpec.describe SingleDateAnswer, type: :model do
  it { should belong_to(:step) }

  describe "#response" do
    it "returns a date" do
      answer = build(:single_date_answer, response: Date.new(2020, 10, 1))
      expect(answer.response).to eq(Date.new(2020, 10, 1))
    end
  end

  describe "validations" do
    it "validates missing response" do
      answer = build(:single_date_answer, response: nil)

      expect(answer.valid?).to eq(false)
      expect(answer.errors.full_messages.first).to include(I18n.t("activerecord.errors.models.single_date_answer.attributes.response"))
    end
  end

  describe "#update_task_counters" do
    it "increments the task tally via callback" do
      task = create(:task)
      expect(task.step_tally["answered"]).to eq 0

      step_1 = create(:step, :single_date, hidden: false, task: task)
      answer_1 = create(:single_date_answer, step: step_1)

      expect(task.step_tally["answered"]).to eq 1

      answer_1.destroy

      expect(task.step_tally["answered"]).to eq 0
    end
  end
end
