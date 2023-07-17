describe Support::CaseLevelChangePresenter do
  subject(:presenter) { described_class.new(interaction) }

  let(:agent) { create(:support_agent, first_name: "CMS", last_name: "User") }
  let(:interaction) { create(:support_interaction, :case_level_changed, agent:, additional_data: { from: "L1", to: "L2" }) }

  describe "#body" do
    it "tells what the level changed from and to and who made the change" do
      expect(presenter.body).to eq "CMS User changed support level from L1 to L2"
    end
  end

  describe "#show_additional_data?" do
    it "returns false" do
      expect(presenter.show_additional_data?).to eq(false)
    end
  end
end
