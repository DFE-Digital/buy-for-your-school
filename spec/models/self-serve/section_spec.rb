RSpec.describe Section, type: :model do
  it { is_expected.to belong_to(:journey) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:contentful_id) }
  end

  describe "default_order" do
    it "orders by order ASC" do
      oldest_section = create(:section, order: 0)
      middle_aged_section = create(:section, order: 1)
      youngest_section = create(:section, order: 2)

      result = described_class.all

      expect(result.first).to eq(oldest_section)
      expect(result.second).to eq(middle_aged_section)
      expect(result.third).to eq(youngest_section)
    end
  end

  describe "#incomplete?" do
    it "returns true if all steps in the section are not complete" do
      task = create(:task)
      question = create(:step, :radio, task:)
      statement = create(:step, :statement, task:)
      section = create(:section, tasks: [task])

      expect(section.incomplete?).to be true

      create(:radio_answer, step: question)
      statement.acknowledge!

      expect(section.incomplete?).to be false
    end
  end
end
