RSpec.describe User, type: :model do
  around do |example|
    ClimateControl.modify(PROC_OPS_TEAM: "DSI Caseworkers") do
      example.run
    end
  end

  let!(:caseworker) { create(:user, :caseworker) }
  let!(:buyer) { create(:user, :one_supported_school) }

  describe ".internal" do
    it "returns internal users only" do
      expect(described_class.internal.count).to eq 1
      expect(described_class.internal[0].first_name).to eq "Procurement"
    end
  end

  describe "#internal?" do
    it "is true for members of the 'Proc Ops' organisation" do
      expect(caseworker.internal?).to be true
      expect(buyer.internal?).to be false
    end
  end
end
