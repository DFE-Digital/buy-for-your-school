class RemoveFrameworkNameFromSupportProcurements < ActiveRecord::Migration[6.1]
  def change
    remove_column :support_procurements, :framework_name, :string
  end
end
