module ProcurementStageHelpers
  def define_procurement_stages(stages)
    stages.each do |stage, sub_stages|
      sub_stages.each do |sub_stage|
        create(:support_procurement_stage, stage:, title: sub_stage, key: sub_stage.parameterize(separator: "_"))
      end
    end
  end

  def define_basic_procurement_stages
    define_procurement_stages(
      0 => %w[Need],
      2 => ["Tender preparation"],
      5 => %w[Enquiry],
    )
  end

  def need_stage = Support::ProcurementStage.find_by(key: "need")

  def tender_prep_stage = Support::ProcurementStage.find_by(key: "tender_preparation")

  def enquiry_stage = Support::ProcurementStage.find_by(key: "enquiry")
end
