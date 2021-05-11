require "rails_helper"

RSpec.describe Section, type: :model do
  it { should belong_to(:journey) }

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
end
