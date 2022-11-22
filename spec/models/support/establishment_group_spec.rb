require "rails_helper"

RSpec.describe Support::EstablishmentGroup, type: :model do
  it { is_expected.to belong_to(:establishment_group_type) }

  describe "#self.find_by_gias_id" do
    it "delegates to find_by" do
      allow(described_class).to receive(:find_by).with(uid: "123")

      described_class.find_by_gias_id("123")
    end
  end

  describe "#gias_id" do
    let(:establishment_group) { create(:support_establishment_group, uid: "123") }

    it "returns the uid" do
      expect(establishment_group.gias_id).to eq establishment_group.uid
    end
  end
end
