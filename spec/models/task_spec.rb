require "rails_helper"

RSpec.describe Task, type: :model do
  it { should belong_to(:section) }
  it { should have_many(:steps) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:contentful_id) }
  end

  describe "#visible_steps" do
    it "only returns visible steps" do
      task = FactoryBot.create(:task)
      visible_step = FactoryBot.create(:step, :radio, hidden: false, task: task)
      hidden_step = FactoryBot.create(:step, :radio, hidden: true, task: task)

      expect(task.visible_steps).to eq [visible_step]
      expect(task.steps).to match_array [visible_step, hidden_step]
    end
  end
end
