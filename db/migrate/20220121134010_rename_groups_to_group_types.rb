class RenameGroupsToGroupTypes < ActiveRecord::Migration[6.1]
  def change
    rename_table :support_groups, :support_group_types
    rename_column :support_establishment_types, :group_id, :group_type_id
  end
end
