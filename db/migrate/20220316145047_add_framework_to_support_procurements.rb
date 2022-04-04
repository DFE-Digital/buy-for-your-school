class AddFrameworkToSupportProcurements < ActiveRecord::Migration[6.1]
  def change
    add_reference :support_procurements, :framework, foreign_key: { to_table: :support_frameworks }, type: :uuid
  end
end
