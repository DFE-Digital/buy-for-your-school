describe Support::ProcurementStagePresenter do
  subject(:presenter) { described_class.new(procurement_stage) }

  let(:procurement_stage) { create(:support_procurement_stage, title: "Tender preparation", stage: 2, key: "tender_preparation") }

  describe "#detailed_title" do
    it "returns the full title with stage number" do
      expect(presenter.detailed_title).to eq("Stage 2 - Tender preparation")
    end
  end

  describe "#detailed_title_short" do
    it "returns the full title with shortened stage number" do
      expect(presenter.detailed_title_short).to eq("S2 - Tender preparation")
    end
  end

  describe "#stage_indicator" do
    it "returns 'S' followed by the stage number" do
      expect(presenter.stage_indicator).to eq("S2")
    end
  end

  describe "#stage_label" do
    it "returns the stage" do
      expect(presenter.stage_label).to eq("Stage 2")
    end
  end
end
