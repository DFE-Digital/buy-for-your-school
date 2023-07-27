RSpec.describe User, type: :model do
  let!(:analyst) { create(:user, :analyst) }
  let!(:not_analyst) { create(:user) }

  describe ".analysts" do
    it "returns users with the analyst role" do
      users = described_class.analysts
      expect(users.size).to eq 1
      expect(users.first.roles.first).to eq "analyst"
    end
  end

  describe "#analyst?" do
    it "returns true if the user is an analyst" do
      expect(analyst.analyst?).to be true
    end

    it "returns false if the user is not an analyst" do
      expect(not_analyst.analyst?).to be false
    end
  end
end
