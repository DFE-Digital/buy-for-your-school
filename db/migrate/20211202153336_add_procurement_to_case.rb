class AddProcurementToCase < ActiveRecord::Migration[6.1]
  def change
    add_reference :support_cases, :procurement, null: true, foreign_key: { to_table: :support_procurements }, type: :uuid
  end
end
