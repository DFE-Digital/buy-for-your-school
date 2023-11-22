class AddFrameworksFrameworkIdToSupportProcurements < ActiveRecord::Migration[7.1]
  def change
    add_column :support_procurements, :frameworks_framework_id, :uuid
  end
end
