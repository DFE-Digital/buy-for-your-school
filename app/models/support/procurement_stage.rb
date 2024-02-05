module Support
  class ProcurementStage < ApplicationRecord
    has_many :cases, class_name: "Support::Case"

    scope :substages_for_stage, ->(stage) { where(key: substage_keys_for_stage(stage)) }

    def self.stages = Support::ProcurementStage.distinct.order(:stage).pluck(:stage)

    def self.substage_keys_for_stage(stage)
      # These keys are hardwired in order of case lifecycle rather than looked up (which would lose / randomise the order)
      case stage
      when 0
        %i[need]
      when 1
        %i[information_gathering market_analysis sign_participation_agreement stage_1_approval]
      when 2
        %i[tender_preparation school_sign_off_of_tender_pack out_to_tender response_compliance_check stage_2_approval]
      when 3
        %i[stage_3_evaluation moderation school_sign_off_of_moderation_and_award_decision stage_3_approval]
      when 4
        %i[award_and_standstill handover procurement_complete]
      end
    end
  end
end
