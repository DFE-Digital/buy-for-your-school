RSpec.describe Section, "#next_incomplete_task", type: :model do
  subject(:section) { create(:section, tasks: [task_1, task_2, task_3]) }

  let!(:task_1) { create(:task, order: 0) }
  let!(:question_1) { create(:step, :radio, task: task_1) }
  let!(:statement_1) { create(:step, :statement, task: task_1) }

  let!(:task_2) { create(:task, order: 1) }
  let!(:question_2) { create(:step, :radio, task: task_2) }
  let!(:statement_2) { create(:step, :statement, task: task_2) }

  let!(:task_3) { create(:task, order: 2) }
  let!(:question_3) { create(:step, :radio, task: task_3) }
  let!(:statement_3) { create(:step, :statement, task: task_3) }

  context "when a task is provided" do
    it "returns the next incomplete task in order or nil" do
      expect(section.next_incomplete_task(task_1)).to be task_2

      # complete task 2
      create(:radio_answer, step: question_2)
      statement_2.acknowledge!

      expect(section.next_incomplete_task(task_1)).to be task_3

      # complete task 3
      create(:radio_answer, step: question_3)
      statement_3.acknowledge!

      expect(section.next_incomplete_task(task_1)).to be_nil
    end
  end

  context "with no parameters" do
    it "returns the first incomplete task in order or nil" do
      expect(section.next_incomplete_task).to be task_1

      # complete task 1
      create(:radio_answer, step: question_1)
      statement_1.acknowledge!

      expect(section.next_incomplete_task).to be task_2

      # complete task 2
      create(:radio_answer, step: question_2)
      statement_2.acknowledge!

      expect(section.next_incomplete_task).to be task_3

      # complete task 3
      create(:radio_answer, step: question_3)
      statement_3.acknowledge!

      expect(section.next_incomplete_task).to be_nil
    end
  end
end
