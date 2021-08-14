RSpec.describe Journey, type: :model do
  subject(:journey) { build(:journey, category: category) }

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
end
