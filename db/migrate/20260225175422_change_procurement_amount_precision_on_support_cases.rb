class ChangeProcurementAmountPrecisionOnSupportCases < ActiveRecord::Migration[7.2]
  def up
    change_column :support_cases, :procurement_amount, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :support_cases, :procurement_amount, :decimal, precision: 9, scale: 2
  end
end
