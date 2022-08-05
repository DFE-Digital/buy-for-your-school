RSpec.describe Journey, type: :model do
  subject(:journey) { build(:journey, category:) }

  let(:category) { build(:category) }

  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :category }

  it { is_expected.to have_many :sections }
  it { is_expected.to have_many :tasks }
  it { is_expected.to have_many :steps }

  describe "#started" do
    it "defaults to false" do
      expect(journey.started).to be false
    end
  end

  describe "#start!" do
    it "sets started to true" do
      journey.start!
      expect(journey.started).to be true
    end
  end

  describe "#sections_with_tasks" do
    it "returns associated sections with tasks" do
      journey.save!
      create(:section, :with_tasks, tasks_count: 2, journey:)
      expect(journey.sections_with_tasks.count).to eq 1
      expect(journey.sections_with_tasks.first.tasks.count).to eq 2
      expect(journey.sections_with_tasks.first.tasks[0]).not_to be nil
      expect(journey.sections_with_tasks.first.tasks[1]).not_to be nil
    end
  end
end
