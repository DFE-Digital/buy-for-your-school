class AddSharePointFolderIdToCases < ActiveRecord::Migration[7.1]
  def change
    add_column :support_cases, :sharepoint_folder_id, :string
  end
end
