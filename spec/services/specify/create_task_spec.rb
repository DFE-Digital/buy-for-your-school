require "rails_helper"

RSpec.describe CreateTask do
  let(:section) { create(:section) }
  let(:contentful_task) { double(id: "5m26U35YLau4cOaJq6FXZA", title: "Task 1") }

  describe "#call" do
    context "when the task is valid" do
      it "creates a new task" do
        expect { described_class.new(section:, contentful_task:, order: 0).call }
          .to change(Task, :count).by(1)
        expect(Task.last.title).to eql("Task 1")
        expect(Task.last.contentful_id).to eql("5m26U35YLau4cOaJq6FXZA")
        expect(Task.last.section).to eql(section)
        expect(Task.last.order).to be(0)
      end
    end

    context "when the task is invalid" do
      before { allow_any_instance_of(Task).to receive(:save!).and_raise(ActiveRecord::RecordInvalid) }

      it "raises UnexpectedContentfulModel" do
        expect { described_class.new(section:, contentful_task:, order: 0).call }
          .to raise_error(CreateTask::UnexpectedContentfulModel)
          .and change(Task, :count).by(0)
      end
    end
  end
end
