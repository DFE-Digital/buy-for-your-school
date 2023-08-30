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
      Support::SeedProcurementStages.new.call

      need_stage = Support::ProcurementStage.find_by(key: "need")
      out_to_tender_stage = Support::ProcurementStage.find_by(key: "out_to_tender")
      handover_stage = Support::ProcurementStage.find_by(key: "handover")

      create(:support_case, :opened, value: 10.00, category: ict, procurement_stage: need_stage)
      create(:support_case, :on_hold, value: 5.00, category: ict, procurement_stage: need_stage)
      create(:support_case, :on_hold, value: 1.00, category: ict, procurement_stage: need_stage)

      create(:support_case, :opened, value: 10.00, category: ict, procurement_stage: out_to_tender_stage)
      create(:support_case, :opened, value: 5.00, category: ict, procurement_stage: out_to_tender_stage)
      create(:support_case, :initial, value: 1.00, category: ict, procurement_stage: out_to_tender_stage)
      create(:support_case, :initial, value: 1.00, category: ict, procurement_stage: out_to_tender_stage)

      create(:support_case, :on_hold, value: 2.00, category: ict, procurement_stage: handover_stage)
      create(:support_case, :on_hold, value: 3.00, category: ict, procurement_stage: handover_stage)
      create(:support_case, :initial, value: 4.00, category: ict, procurement_stage: handover_stage)
      create(:support_case, :initial, value: 2.00, category: ict, procurement_stage: handover_stage)

      create(:support_case, :opened, value: 2.00, category: ict)
      create(:support_case, :on_hold, value: 2.00, category: ict)
      create(:support_case, :initial, value: 2.00, category: ict)
    end

    it "overview of each case stage in order with unspecified last" do
      expect(results.to_a.length).to eq(18) # 17 stages + unspecified

      need_row = results[0]
      expect(need_row.procurement_stage_title).to eq("Need")
      expect(need_row.open_cases).to eq(1)
      expect(need_row.on_hold_cases).to eq(2)
      expect(need_row.new_cases).to eq(0)
      expect(need_row.live_value).to eq(16.00)

      information_gathering_row = results[1]
      expect(information_gathering_row.procurement_stage_title).to eq("Information gathering")
      expect(information_gathering_row.open_cases).to eq(0)
      expect(information_gathering_row.on_hold_cases).to eq(0)
      expect(information_gathering_row.new_cases).to eq(0)
      expect(information_gathering_row.live_value).to eq(0.00)

      market_analysis_row = results[2]
      expect(market_analysis_row.procurement_stage_title).to eq("Market analysis")
      expect(market_analysis_row.open_cases).to eq(0)
      expect(market_analysis_row.on_hold_cases).to eq(0)
      expect(market_analysis_row.new_cases).to eq(0)
      expect(market_analysis_row.live_value).to eq(0.00)

      sign_participation_agreement_row = results[3]
      expect(sign_participation_agreement_row.procurement_stage_title).to eq("Sign Participation agreement")
      expect(sign_participation_agreement_row.open_cases).to eq(0)
      expect(sign_participation_agreement_row.on_hold_cases).to eq(0)
      expect(sign_participation_agreement_row.new_cases).to eq(0)
      expect(sign_participation_agreement_row.live_value).to eq(0.00)

      stage_1_approval_row = results[4]
      expect(stage_1_approval_row.procurement_stage_title).to eq("Stage 1 Approval")
      expect(stage_1_approval_row.open_cases).to eq(0)
      expect(stage_1_approval_row.on_hold_cases).to eq(0)
      expect(stage_1_approval_row.new_cases).to eq(0)
      expect(stage_1_approval_row.live_value).to eq(0.00)

      tender_preparation_row = results[5]
      expect(tender_preparation_row.procurement_stage_title).to eq("Tender preparation")
      expect(tender_preparation_row.open_cases).to eq(0)
      expect(tender_preparation_row.on_hold_cases).to eq(0)
      expect(tender_preparation_row.new_cases).to eq(0)
      expect(tender_preparation_row.live_value).to eq(0.00)

      school_sign_off_of_tender_pack_row = results[6]
      expect(school_sign_off_of_tender_pack_row.procurement_stage_title).to eq("School sign-off of tender pack")
      expect(school_sign_off_of_tender_pack_row.open_cases).to eq(0)
      expect(school_sign_off_of_tender_pack_row.on_hold_cases).to eq(0)
      expect(school_sign_off_of_tender_pack_row.new_cases).to eq(0)
      expect(school_sign_off_of_tender_pack_row.live_value).to eq(0.00)

      out_to_tender_row = results[7]
      expect(out_to_tender_row.procurement_stage_title).to eq("Out to Tender")
      expect(out_to_tender_row.open_cases).to eq(2)
      expect(out_to_tender_row.on_hold_cases).to eq(0)
      expect(out_to_tender_row.new_cases).to eq(2)
      expect(out_to_tender_row.live_value).to eq(17.00)

      response_compliance_check_row = results[8]
      expect(response_compliance_check_row.procurement_stage_title).to eq("Response compliance check")
      expect(response_compliance_check_row.open_cases).to eq(0)
      expect(response_compliance_check_row.on_hold_cases).to eq(0)
      expect(response_compliance_check_row.new_cases).to eq(0)
      expect(response_compliance_check_row.live_value).to eq(0.00)

      stage_2_approval_row = results[9]
      expect(stage_2_approval_row.procurement_stage_title).to eq("Stage 2 Approval")
      expect(stage_2_approval_row.open_cases).to eq(0)
      expect(stage_2_approval_row.on_hold_cases).to eq(0)
      expect(stage_2_approval_row.new_cases).to eq(0)
      expect(stage_2_approval_row.live_value).to eq(0.00)

      stage_3_evaluation_row = results[10]
      expect(stage_3_evaluation_row.procurement_stage_title).to eq("Stage 3 Evaluation")
      expect(stage_3_evaluation_row.open_cases).to eq(0)
      expect(stage_3_evaluation_row.on_hold_cases).to eq(0)
      expect(stage_3_evaluation_row.new_cases).to eq(0)
      expect(stage_3_evaluation_row.live_value).to eq(0.00)

      moderation_row = results[11]
      expect(moderation_row.procurement_stage_title).to eq("Moderation")
      expect(moderation_row.open_cases).to eq(0)
      expect(moderation_row.on_hold_cases).to eq(0)
      expect(moderation_row.new_cases).to eq(0)
      expect(moderation_row.live_value).to eq(0.00)

      school_sign_off_of_moderation_and_award_decision_row = results[12]
      expect(school_sign_off_of_moderation_and_award_decision_row.procurement_stage_title).to eq("School sign-off of moderation & award decision")
      expect(school_sign_off_of_moderation_and_award_decision_row.open_cases).to eq(0)
      expect(school_sign_off_of_moderation_and_award_decision_row.on_hold_cases).to eq(0)
      expect(school_sign_off_of_moderation_and_award_decision_row.new_cases).to eq(0)
      expect(school_sign_off_of_moderation_and_award_decision_row.live_value).to eq(0.00)

      stage_3_approval_row = results[13]
      expect(stage_3_approval_row.procurement_stage_title).to eq("Stage 3 Approval")
      expect(stage_3_approval_row.open_cases).to eq(0)
      expect(stage_3_approval_row.on_hold_cases).to eq(0)
      expect(stage_3_approval_row.new_cases).to eq(0)
      expect(stage_3_approval_row.live_value).to eq(0.00)

      award_and_standstill_row = results[14]
      expect(award_and_standstill_row.procurement_stage_title).to eq("Award & standstill")
      expect(award_and_standstill_row.open_cases).to eq(0)
      expect(award_and_standstill_row.on_hold_cases).to eq(0)
      expect(award_and_standstill_row.new_cases).to eq(0)
      expect(award_and_standstill_row.live_value).to eq(0.00)

      handover_row = results[15]
      expect(handover_row.procurement_stage_title).to eq("Handover")
      expect(handover_row.open_cases).to eq(0)
      expect(handover_row.on_hold_cases).to eq(2)
      expect(handover_row.new_cases).to eq(2)
      expect(handover_row.live_value).to eq(11.00)

      procurement_complete_row = results[16]
      expect(procurement_complete_row.procurement_stage_title).to eq("Procurement complete")
      expect(procurement_complete_row.open_cases).to eq(0)
      expect(procurement_complete_row.on_hold_cases).to eq(0)
      expect(procurement_complete_row.new_cases).to eq(0)
      expect(procurement_complete_row.live_value).to eq(0.00)

      unspecified_row = results[17]
      expect(unspecified_row.procurement_stage_title).to eq("Unspecified")
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
      create(:support_case, :opened, support_level: :L1, value: 10.00, category: ict, organisation: nil, procurement: create(:support_procurement, stage: nil))
      create(:support_case, :on_hold, support_level: nil, value: nil, category: ict, procurement: create(:support_procurement, stage: nil))
      create(:support_case, :on_hold, support_level: :L1, value: nil, category: ict, procurement_stage: create(:support_procurement_stage))
    end

    it { expect(report.missing_level_cases).to eq(1) }
    it { expect(report.missing_stage_cases).to eq(2) }
    it { expect(report.missing_value_cases).to eq(2) }
    it { expect(report.missing_org_cases).to eq(1) }
  end
end
