class AddSameSupplierUsedToFrameworkRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :framework_requests, :same_supplier_used, :integer
  end
end
