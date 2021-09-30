RSpec.describe JourneyPresenter do
  describe "#sections" do
    it "returns decorated sections" do
      journey = build(:journey, :with_sections, sections_count: 2)
      presenter = described_class.new(journey)
      expect(presenter.sections).to all be_a(SectionPresenter)
    end
  end

  describe "#steps" do
    it "returns decorated steps" do
      task = build(:task, :with_steps, steps_count: 2)
      section = build(:section, tasks: [task])
      journey = build(:journey, sections: [section])
      presenter = described_class.new(journey)
      expect(presenter.steps).to all be_a(StepPresenter)
    end
  end

  describe "#created_at" do
    it "returns a formatted date" do
      journey = build(:journey, created_at: Time.zone.local(2021, 9, 8))
      presenter = described_class.new(journey)
      expect(presenter.created_at).to eq " 8 September 2021"
    end
  end

  describe "#category" do
    it "returns a decorated category" do
      journey = build(:journey)
      presenter = described_class.new(journey)
      expect(presenter.category).to be_kind_of(CategoryPresenter)
    end
  end
end
