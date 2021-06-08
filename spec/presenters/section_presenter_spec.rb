require "rails_helper"

RSpec.describe SectionPresenter do
  describe "#tasks" do
    it "returns decorated tasks" do
      section = build(:section, :with_tasks, tasks_count: 2)
      presenter = described_class.new(section)
      expect(presenter.tasks).to all be_a(TaskPresenter)
    end
  end
end
