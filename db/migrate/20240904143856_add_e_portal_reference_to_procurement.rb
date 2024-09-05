class AddEPortalReferenceToProcurement < ActiveRecord::Migration[7.1]
  def change
    add_column :support_procurements, :e_portal_reference, :string, default: nil
  end
end
