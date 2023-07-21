describe Support::CaseProcurementStageChangePresenter do
  subject(:presenter) { described_class.new(interaction) }

  let(:agent) { create(:support_agent, first_name: "CMS", last_name: "User") }
  let(:interaction) { create(:support_interaction, :case_procurement_stage_changed, agent:, additional_data: { from: need_stage.id, to: tender_prep_stage.id }) }

  before { define_basic_procurement_stages }

  describe "#body" do
    it "tells what the procurement stage changed from and to and who made the change" do
      expect(presenter.body).to eq "CMS User changed procurement stage from Stage 0 - Need to Stage 2 - Tender preparation"
    end
  end

  describe "#show_additional_data?" do
    it "returns false" do
      expect(presenter.show_additional_data?).to eq(false)
    end
  end
end
