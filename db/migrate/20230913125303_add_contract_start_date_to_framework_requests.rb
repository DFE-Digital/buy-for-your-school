class AddContractStartDateToFrameworkRequests < ActiveRecord::Migration[7.0]
  def change
    change_table :framework_requests, bulk: true do |t|
      t.column :contract_start_date_known, :boolean
      t.column :contract_start_date, :date
    end
  end
end
