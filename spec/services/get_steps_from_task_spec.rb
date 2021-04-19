require "rails_helper"

RSpec.describe GetStepsFromTask do
  describe "#call" do
    it "returns the list of entry objects referenced by the step list" do
      task = fake_contentful_section(
        contentful_fixture_filename: "tasks/checkboxes-task.json"
      )
      stub_contentful_task_steps(tasks: [task])

      result = described_class.new(task: task).call

      expect(result).to be_kind_of(Array)
      # INFO: We should test this is a Contentful::Entry however it wasn't
      # possible to create an instance_double due to an unusual way the object
      # is constructed within the gem. Creating the object seems overly complex.
      expect(result.first.id).to eq("checkboxes-question")
    end
  end
end
