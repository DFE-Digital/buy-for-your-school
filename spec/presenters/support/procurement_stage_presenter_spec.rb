describe Support::ProcurementStagePresenter do
  subject(:presenter) { described_class.new(procurement_stage) }

  let(:procurement_stage) { create(:support_procurement_stage, title: "Tender preparation", stage: 2, key: "tender_preparation") }

  describe "#title" do
    it "returns the full title with stage number" do
      expect(presenter.title).to eq("Stage 2 - Tender preparation")
    end
  end
end
