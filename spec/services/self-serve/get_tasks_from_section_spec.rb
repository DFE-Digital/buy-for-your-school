require "rails_helper"

RSpec.describe GetTasksFromSection do
  describe "#call" do
    it "returns the list of entry objects referenced by the task list" do
      section = fake_contentful_section(
        contentful_fixture_filename: "sections/multiple-tasks-section.json",
      )
      stub_contentful_tasks(sections: [section])

      result = described_class.new(section:).call

      expect(result).to be_kind_of(Array)
      # INFO: We should test this is a Contentful::Entry however it wasn't
      # possible to create an instance_double due to an unusual way the object
      # is constructed within the gem. Creating the object seems overly complex.
      expect(result.first.id).to eq("checkboxes-task")
    end
  end
end
