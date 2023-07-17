class AddProcurementStageToCases < ActiveRecord::Migration[7.0]
  def change
    add_reference :support_cases, :procurement_stage, foreign_key: { to_table: :support_procurement_stages }, type: :uuid
  end
end
