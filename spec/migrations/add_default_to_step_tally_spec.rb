require Rails.root.join("db/migrate/20210729144528_add_default_to_step_tally")

RSpec.describe AddDefaultToStepTally do
  include_context "with data migrations"

  let(:previous_version) { 20_210_721_115_748 }
  let(:current_version) { 20_210_729_144_528 }

  context "when there are broken tasks" do
    before do
      section = create(:section, contentful_id: "checkboxes-question")

      # 1 of 3 steps hidden
      task_1 = create(:task, section: section, title: "Task 1")
      task_1_steps = create_list(:step, 3, :radio, task: task_1)
      task_1_steps.first.update!(hidden: true)

      # 1 of 5 steps answered
      task_2 = create(:task, section: section, title: "Task 2")
      task_2_steps = create_list(:step, 5, :currency, task: task_2)
      create(:currency_answer, step: task_2_steps.first)

      Task.update_all(step_tally: nil)

      stub_contentful_category(fixture_filename: "journey-with-multiple-entries.json")
    end

    it "populates the step_tally" do
      expect(Rollbar).to receive(:info).with("Migration: Missing Task step_tallies", task_count: 2)

      expect { up }.to change { Task.where(step_tally: nil).count }.from(2).to(0)

      task_1 = Task.find_by_title("Task 1")
      task_2 = Task.find_by_title("Task 2")

      expect(task_1.step_tally).to include("total" => 3, "hidden" => 1)
      expect(task_2.step_tally).to include("total" => 5, "answered" => 1)
    end
  end
end
