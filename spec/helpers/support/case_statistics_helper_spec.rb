describe Support::CaseStatisticsHelper do
  describe "#filter_cases_params" do
    it "returns given parameters as filter_cases parameters" do
      expect(helper.filter_cases_params(state: "initial", level: "1", stage: "handover"))
      .to eq({ filter_cases: { state: "initial", level: "1", stage: "handover" } })
    end
  end
end
