class AddEnergyFieldsToFrameworkRequests < ActiveRecord::Migration[7.0]
  def change
    change_table :framework_requests, bulk: true do |t|
      t.column :is_energy_request, :boolean
      t.column :energy_request_about, :integer
      t.column :have_energy_bill, :boolean
      t.column :energy_alternative, :integer
    end
  end
end
