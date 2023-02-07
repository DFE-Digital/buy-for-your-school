RSpec.describe JourneyPresenter do
  subject(:presenter) { described_class.new(journey) }

  let(:journey) { build(:journey) }

  it { is_expected.to delegate_method(:slug).to(:category).with_prefix(:category) }

  describe "#sections" do
    let(:journey) { build(:journey, :with_sections, sections_count: 2) }

    it "returns decorated sections" do
      expect(presenter.sections).to all be_a(SectionPresenter)
    end
  end

  describe "#steps" do
    let(:task) { build(:task, :with_steps, steps_count: 2) }
    let(:section) { build(:section, tasks: [task]) }
    let(:journey) { build(:journey, sections: [section]) }

    it "returns decorated steps" do
      expect(presenter.steps).to all be_a(StepPresenter)
    end
  end

  describe "#created_at" do
    let(:journey) { build(:journey, created_at: Time.zone.local(2021, 9, 8)) }

    it "returns a formatted date" do
      expect(presenter.created_at).to eq " 8 September 2021"
    end
  end

  describe "#category" do
    it "returns a decorated category" do
      expect(presenter.category).to be_kind_of(CategoryPresenter)
    end
  end
end
