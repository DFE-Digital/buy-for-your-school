class RenameEnergyBillFields < ActiveRecord::Migration[7.0]
  def change
    rename_column :energy_bills, :support_cases_id, :support_case_id
    rename_column :energy_bills, :framework_requests_id, :framework_request_id
  end
end
