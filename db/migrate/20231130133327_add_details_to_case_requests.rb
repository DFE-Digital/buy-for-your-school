class AddDetailsToCaseRequests < ActiveRecord::Migration[7.1]
  def change
    change_table :case_requests, bulk: true do |t|
      t.column :same_supplier_used, :integer
      t.column :contract_start_date_known, :boolean
      t.column :contract_start_date, :date
    end
  end
end
