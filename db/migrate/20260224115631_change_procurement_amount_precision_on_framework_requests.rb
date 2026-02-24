class ChangeProcurementAmountPrecisionOnFrameworkRequests < ActiveRecord::Migration[7.2]
  def up
    change_column :framework_requests, :procurement_amount, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :framework_requests, :procurement_amount, :decimal, precision: 9, scale: 2
  end
end
