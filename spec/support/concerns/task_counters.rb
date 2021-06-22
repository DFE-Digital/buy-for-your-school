require "rails_helper"

shared_examples_for "task_counters" do |step, answer|
  let (:model) {create (described_class.to_s.underscore)}

  it "calls update_task_counters after commit" do
    expect(model).to receive(:update_task_counters)
    model.save
  end

  it "increments the task tally via callback" do
    task = create(:task)
    expect(task.step_tally["answered"]).to eq 0

    step_1 = create(:step, step, hidden: false, task: task)
    answer_1 = create(answer, step: step_1)

    expect(task.step_tally["answered"]).to eq 1

    answer_1.destroy

    expect(task.step_tally["answered"]).to eq 0
  end
end
