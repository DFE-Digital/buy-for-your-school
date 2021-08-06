require "rails_helper"

RSpec.describe CreateTask do
  let(:section) { create(:section) }
  let(:contentful_task) { double(id: "5m26U35YLau4cOaJq6FXZA", title: "Task 1") }

  describe "#call" do
    context "when the task is valid" do
      it "creates a new task" do
        expect { described_class.new(section: section, contentful_task: contentful_task, order: 0).call }
          .to change(Task, :count).by(1)
        expect(Task.last.title).to eql("Task 1")
        expect(Task.last.contentful_id).to eql("5m26U35YLau4cOaJq6FXZA")
        expect(Task.last.section).to eql(section)
        expect(Task.last.order).to be(0)
      end
    end

    # TODO: test coverage for raised exceptions in service objects
    # context "when the task is invalid" do
    #   it "raises UnexpectedContentfulModel" do
    #     expect { described_class.new(section: section, contentful_task: contentful_task, order: 0).call }
    #       .not_to change(Task, :count).by(1)
    #   end
    # end
  end
end
