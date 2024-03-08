class UpdateProcurementSubstages < ActiveRecord::Migration[7.1]
  def change
    change_table :support_procurement_stages, bulk: true do |t|
      # add a lifecycle_order column
      t.column :lifecycle_order, :integer
    end

    reversible do |direction|
      direction.up do
        # make "sign_participation_agreement"s stage Stage 0
        Support::ProcurementStage.find_by(key: "sign_participation_agreement").update!(stage: 0)

        # make a new "participation_agreement_sent" in stage 0
        Support::ProcurementStage.create!(key: "participation_agreement_sent", title: "Participation Agreement sent", stage: 0)
      end

      direction.down do
        # revert "sign_participation_agreement"s stage to Stage 1
        Support::ProcurementStage.find_by(key: "sign_participation_agreement").update!(stage: 1)

        # delete "participation_agreement_sent"
        Support::ProcurementStage.find_by(key: "participation_agreement_sent").destroy!
      end
    end
  end
end
