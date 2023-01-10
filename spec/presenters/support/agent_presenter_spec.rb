RSpec.describe Support::AgentPresenter do
  subject(:presenter) { described_class.new(agent) }

  let(:agent) { build(:support_agent, first_name: "Ronald", last_name: "McDonald", support_tower:) }
  let(:support_tower) { nil }

  describe "#full_name" do
    it "joins first and last name" do
      expect(presenter.full_name).to eq("Ronald McDonald")
    end
  end

  describe "#guest?" do
    it "returns false" do
      expect(presenter.guest?).to be false
    end
  end

  describe "#as_json" do
    it "returns the full name" do
      expect(presenter.as_json).to include(
        "full_name" => "Ronald McDonald",
      )
    end
  end

  describe "#tower_name" do
    context "when the agent is assigned to a tower" do
      let(:support_tower) { build(:support_tower, title: "Services") }

      it "returns the tower name" do
        expect(presenter.tower_name).to eq "Services Tower"
      end
    end

    context "when the agent is not assigned to a tower" do
      let(:support_tower) { nil }

      it "returns no tower" do
        expect(presenter.tower_name).to eq "No Tower"
      end
    end
  end
end
