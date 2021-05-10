require "rails_helper"

RSpec.describe Section, type: :model do
  it { should belong_to(:journey) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:contentful_id) }
  end

  describe "default_order" do
    it "orders by created_at ASC" do
      oldest_section = create(:section, created_at: 3.days.ago)
      middle_aged_section = create(:section, created_at: 2.days.ago)
      youngest_section = create(:section, created_at: 1.days.ago)

      result = described_class.all

      expect(result.first).to eq(oldest_section)
      expect(result.second).to eq(middle_aged_section)
      expect(result.third).to eq(youngest_section)
    end
  end
end
