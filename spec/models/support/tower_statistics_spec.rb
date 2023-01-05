require "rails_helper"

describe Support::TowerStatistics do
  subject(:report) { described_class.new(tower_slug: "ict") }

  let(:ict) { create(:support_category, title: "Laptops", with_tower: "ICT") }

  describe "top level statistics" do
    before do
      create_list(:support_case, 3, :opened, value: 1.00, category: ict)
      create_list(:support_case, 2, :on_hold, value: 10.00, category: ict)
      create(:support_case, :initial, value: 5.50, category: ict)
    end

    it "has an overview of cases" do
      expect(report.live_cases).to eq(6)
      expect(report.live_value).to eq(28.50)
      expect(report.open_cases).to eq(3)
      expect(report.on_hold_cases).to eq(2)
      expect(report.new_cases).to eq(1)
    end
  end

  describe "breakdown of cases by stage" do
    subject(:results) { report.breakdown_of_cases_by_stage }

    before do
      create(:support_case, :opened, :stage_need, value: 10.00, category: ict)
      create(:support_case, :on_hold, :stage_need, value: 5.00, category: ict)
      create(:support_case, :on_hold, :stage_need, value: 1.00, category: ict)

      create(:support_case, :opened, :stage_go_to_market, value: 10.00, category: ict)
      create(:support_case, :opened, :stage_go_to_market, value: 5.00, category: ict)
      create(:support_case, :initial, :stage_go_to_market, value: 1.00, category: ict)
      create(:support_case, :initial, :stage_go_to_market, value: 1.00, category: ict)

      create(:support_case, :on_hold, :stage_handover, value: 2.00, category: ict)
      create(:support_case, :on_hold, :stage_handover, value: 3.00, category: ict)
      create(:support_case, :initial, :stage_handover, value: 4.00, category: ict)
      create(:support_case, :initial, :stage_handover, value: 2.00, category: ict)

      create(:support_case, :opened, :stage_unspecified, value: 2.00, category: ict)
      create(:support_case, :on_hold, :stage_unspecified, value: 2.00, category: ict)
      create(:support_case, :initial, :stage_unspecified, value: 2.00, category: ict)
    end

    it "overview of each case stage in order with unspecified last" do
      expect(results.to_a.length).to eq(8) # 7 stages + unspecified

      need_row = results[0]
      expect(need_row.stage).to eq("need")
      expect(need_row.open_cases).to eq(1)
      expect(need_row.on_hold_cases).to eq(2)
      expect(need_row.new_cases).to eq(0)
      expect(need_row.live_value).to eq(16.00)

      market_analysis_row = results[1]
      expect(market_analysis_row.stage).to eq("market_analysis")
      expect(market_analysis_row.open_cases).to eq(0)
      expect(market_analysis_row.on_hold_cases).to eq(0)
      expect(market_analysis_row.new_cases).to eq(0)
      expect(market_analysis_row.live_value).to eq(0.00)

      sourcing_options_row = results[2]
      expect(sourcing_options_row.stage).to eq("sourcing_options")
      expect(sourcing_options_row.open_cases).to eq(0)
      expect(sourcing_options_row.on_hold_cases).to eq(0)
      expect(sourcing_options_row.new_cases).to eq(0)
      expect(sourcing_options_row.live_value).to eq(0.00)

      go_to_market_row = results[3]
      expect(go_to_market_row.stage).to eq("go_to_market")
      expect(go_to_market_row.open_cases).to eq(2)
      expect(go_to_market_row.on_hold_cases).to eq(0)
      expect(go_to_market_row.new_cases).to eq(2)
      expect(go_to_market_row.live_value).to eq(17.00)

      evaluation_row = results[4]
      expect(evaluation_row.stage).to eq("evaluation")
      expect(evaluation_row.open_cases).to eq(0)
      expect(evaluation_row.on_hold_cases).to eq(0)
      expect(evaluation_row.new_cases).to eq(0)
      expect(evaluation_row.live_value).to eq(0.00)

      contract_award_row = results[5]
      expect(contract_award_row.stage).to eq("contract_award")
      expect(contract_award_row.open_cases).to eq(0)
      expect(contract_award_row.on_hold_cases).to eq(0)
      expect(contract_award_row.new_cases).to eq(0)
      expect(contract_award_row.live_value).to eq(0.00)

      handover_row = results[6]
      expect(handover_row.stage).to eq("handover")
      expect(handover_row.open_cases).to eq(0)
      expect(handover_row.on_hold_cases).to eq(2)
      expect(handover_row.new_cases).to eq(2)
      expect(handover_row.live_value).to eq(11.00)

      unspecified_row = results[7]
      expect(unspecified_row.stage).to eq("unspecified")
      expect(unspecified_row.open_cases).to eq(1)
      expect(unspecified_row.on_hold_cases).to eq(1)
      expect(unspecified_row.new_cases).to eq(1)
      expect(unspecified_row.live_value).to eq(6.00)
    end
  end

  describe "breakdown of cases by support level" do
    subject(:results) { report.breakdown_of_cases_by_level }

    before do
      create(:support_case, :opened, support_level: :L1, value: 10.00, category: ict)
      create(:support_case, :on_hold, support_level: :L1, value: 5.00, category: ict)
      create(:support_case, :on_hold, support_level: :L1, value: 1.00, category: ict)

      create(:support_case, :opened, support_level: :L2, value: 5.00, category: ict)
      create(:support_case, :on_hold, support_level: :L2, value: 5.00, category: ict)
      create(:support_case, :initial, support_level: :L2, value: 1.00, category: ict)

      create(:support_case, :on_hold, support_level: :L3, value: 2.00, category: ict)
      create(:support_case, :initial, support_level: :L3, value: 3.00, category: ict)
      create(:support_case, :initial, support_level: :L3, value: 4.00, category: ict)

      create(:support_case, :opened, support_level: :L4, value: 2.00, category: ict)
      create(:support_case, :on_hold, support_level: :L4, value: 3.00, category: ict)
      create(:support_case, :initial, support_level: :L4, value: 2.00, category: ict)

      create(:support_case, :opened, support_level: :L5, value: 2.00, category: ict)
      create(:support_case, :on_hold, support_level: :L5, value: 2.00, category: ict)
      create(:support_case, :initial, support_level: :L5, value: 1.20, category: ict)

      create(:support_case, :opened, support_level: nil, value: 2.00, category: ict)
      create(:support_case, :initial, support_level: nil, value: 4.32, category: ict)
      create(:support_case, :initial, support_level: nil, value: 10.00, category: ict)
    end

    it "overview of each case level in order with unspecified last" do
      expect(results.to_a.length).to eq(6) # 5 levels + unspecified

      level_1_row = results[0]
      expect(level_1_row.support_level).to eq("L1")
      expect(level_1_row.open_cases).to eq(1)
      expect(level_1_row.on_hold_cases).to eq(2)
      expect(level_1_row.new_cases).to eq(0)
      expect(level_1_row.live_value).to eq(16.00)

      level_2_row = results[1]
      expect(level_2_row.support_level).to eq("L2")
      expect(level_2_row.open_cases).to eq(1)
      expect(level_2_row.on_hold_cases).to eq(1)
      expect(level_2_row.new_cases).to eq(1)
      expect(level_2_row.live_value).to eq(11.00)

      level_3_row = results[2]
      expect(level_3_row.support_level).to eq("L3")
      expect(level_3_row.open_cases).to eq(0)
      expect(level_3_row.on_hold_cases).to eq(1)
      expect(level_3_row.new_cases).to eq(2)
      expect(level_3_row.live_value).to eq(9.00)

      level_4_row = results[3]
      expect(level_4_row.support_level).to eq("L4")
      expect(level_4_row.open_cases).to eq(1)
      expect(level_4_row.on_hold_cases).to eq(1)
      expect(level_4_row.new_cases).to eq(1)
      expect(level_4_row.live_value).to eq(7.00)

      level_5_row = results[4]
      expect(level_5_row.support_level).to eq("L5")
      expect(level_5_row.open_cases).to eq(1)
      expect(level_5_row.on_hold_cases).to eq(1)
      expect(level_5_row.new_cases).to eq(1)
      expect(level_5_row.live_value).to eq(5.20)

      unspecified_row = results[5]
      expect(unspecified_row.support_level).to eq("unspecified")
      expect(unspecified_row.open_cases).to eq(1)
      expect(unspecified_row.on_hold_cases).to eq(0)
      expect(unspecified_row.new_cases).to eq(2)
      expect(unspecified_row.live_value).to eq(16.32)
    end
  end

  describe "counts of missing data" do
    before do
      create(:support_case, :opened, :stage_unspecified, support_level: :L1, value: 10.00, category: ict)
      create(:support_case, :on_hold, :stage_unspecified, support_level: nil, value: nil, category: ict)
      create(:support_case, :on_hold, :stage_need, support_level: :L1, value: nil, category: ict)
    end

    it { expect(report.missing_level_cases).to eq(1) }
    it { expect(report.missing_stage_cases).to eq(2) }
    it { expect(report.missing_value_cases).to eq(2) }
  end
end
