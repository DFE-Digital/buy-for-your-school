require "rails_helper"

RSpec.describe CreateTask do
  let(:section) { FactoryBot.create(:section) }
  let(:contentful_task) { double(id: "5m26U35YLau4cOaJq6FXZA", title: "Task 1") }

  describe "#call" do
    it "creates a new task" do
      expect { described_class.new(section: section, contentful_task: contentful_task).call }
        .to change { Task.count }.by(1)
      expect(Task.last.title).to eql("Task 1")
      expect(Task.last.contentful_id).to eql("5m26U35YLau4cOaJq6FXZA")
      expect(Task.last.section).to eql(section)
    end
  end
end
