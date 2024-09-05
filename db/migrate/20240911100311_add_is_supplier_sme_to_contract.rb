class AddIsSupplierSmeToContract < ActiveRecord::Migration[7.1]
  def change
    add_column :support_contracts, :is_supplier_sme, :boolean, default: false
  end
end
