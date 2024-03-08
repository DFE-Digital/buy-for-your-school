class SetProcurementSubstageLifecycleOrders < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      direction.up do
        Support::ProcurementStage.find_each do |ps|
          case ps.key

          # Stage 0
          when "need"
            ps.update!(lifecycle_order: 0)
          when "participation_agreement_sent"
            ps.update!(lifecycle_order: 1)
          when "sign_participation_agreement"
            ps.update!(lifecycle_order: 2)

          # Stage 1
          when "information_gathering"
            ps.update!(lifecycle_order: 3)
          when "market_analysis"
            ps.update!(lifecycle_order: 4)
          when "stage_1_approval"
            ps.update!(lifecycle_order: 5)

          # Stage 2
          when "tender_preparation"
            ps.update!(lifecycle_order: 6)
          when "school_sign_off_of_tender_pack"
            ps.update!(lifecycle_order: 7)
          when "out_to_tender"
            ps.update!(lifecycle_order: 8)
          when "response_compliance_check"
            ps.update!(lifecycle_order: 9)
          when "stage_2_approval"
            ps.update!(lifecycle_order: 10)

          # Stage 3
          when "stage_3_evaluation"
            ps.update!(lifecycle_order: 11)
          when "moderation"
            ps.update!(lifecycle_order: 12)
          when "school_sign_off_of_moderation_and_award_decision"
            ps.update!(lifecycle_order: 13)
          when "stage_3_approval"
            ps.update!(lifecycle_order: 14)

          # Stage 4
          when "award_and_standstill"
            ps.update!(lifecycle_order: 15)
          when "handover"
            ps.update!(lifecycle_order: 16)
          when "procurement_complete"
            ps.update!(lifecycle_order: 17)
          end
        end
      end

      direction.down do
        Support::ProcurementStage.find_each do |ps|
          ps.update!(lifecycle_order: nil)
        end
      end
    end
  end
end
