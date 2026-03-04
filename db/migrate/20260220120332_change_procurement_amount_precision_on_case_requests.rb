class ChangeProcurementAmountPrecisionOnCaseRequests < ActiveRecord::Migration[7.2]
  def up
    change_column :case_requests, :procurement_amount, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :case_requests, :procurement_amount, :decimal, precision: 9, scale: 2
  end
end
